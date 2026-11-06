# Claude Code usage : the real % of /usage (same endpoint as the VS Code extension), else the local logs (~/.claude/projects/*/*.jsonl) as an estimate.
# Usage : my_script claude_usage          : waybar json (the tokens of the current 5 h block and its time left)
#         my_script claude_usage report   : the current block and the last 7 days, per model + context per request
#         my_script claude_usage calibrate <5h %> <week %> : read both % in /usage, so the estimated % are right
# Only the sessions of this machine are counted, and the % of the plan limits (shown by /usage in Claude Code)
# isn't in the logs : the block here is an estimate (5 h from its first message, as the reset time shown by /usage).
import glob
import json
import os
import sys
import time
import urllib.request
from collections import defaultdict
from datetime import datetime, timedelta

BLOCK = timedelta(hours=5)
WEEK = timedelta(days=7)
PROJECTS = os.path.expanduser("~/.claude/projects")
LIMITS = os.path.expanduser("~/.config/my_script/claude_limits.json")  # machine-specific, not in the repo


def read_entries(since):
    """(time, model, tokens) of each assistant message after `since`, each message counted once."""
    seen = set()
    entries = []
    for path in glob.glob(f"{PROJECTS}/**/*.jsonl", recursive=True):
        if os.path.getmtime(path) < since.timestamp():
            continue
        with open(path, errors="replace") as f:
            for line in f:
                if '"usage"' not in line:
                    continue
                try:
                    entry = json.loads(line)
                    message = entry["message"]
                    usage = message["usage"]
                    when = datetime.fromisoformat(entry["timestamp"].replace("Z", "+00:00")).astimezone()
                except (ValueError, KeyError, TypeError):
                    continue
                key = (message.get("id"), entry.get("requestId"))
                if key in seen or when < since:
                    continue
                seen.add(key)
                tokens = {
                    "input": usage.get("input_tokens", 0),
                    "output": usage.get("output_tokens", 0),
                    "cache_write": usage.get("cache_creation_input_tokens", 0),
                    "cache_read": usage.get("cache_read_input_tokens", 0),
                }
                entries.append((when, message.get("model", "?"), tokens))
    return sorted(entries, key=lambda e: e[0])


def current_block(entries, now):
    """The entries of the 5 h block still running (None if the last message is older than 5 h)."""
    start, block = None, []
    for entry in entries:
        when = entry[0]
        if start is None or when >= start + BLOCK:
            start, block = when, []
        block.append(entry)
    if start is None or now >= start + BLOCK:
        return None, []
    return start, block


def human(n):
    for unit, size in (("M", 1e6), ("k", 1e3)):
        if n >= size:
            return f"{n / size:.1f}{unit}"
    return str(n)


def total(tokens):
    return sum(tokens.values())


def weighted(entries):
    """Tokens counted against the limits : the cache reads are left out (they are cheap and would dominate)."""
    return sum(t["input"] + t["output"] + t["cache_write"] for _, _, t in entries)


def load_limits():
    try:
        with open(LIMITS) as f:
            return json.load(f)
    except (OSError, ValueError):
        return {}


def real_usage():
    """The real % of /usage (undocumented oauth endpoint, same as the VS Code extension), cached 60 s so the bar
    doesn't hammer it. On a failure (offline, token being refreshed, rate limit) the last good value is kept until
    its reset time : the log-based estimate is far off (124 % seen), so it is only the fallback when there is nothing
    else. None if there is no usable value : the caller falls back to the estimate."""
    cache = os.path.expanduser("~/.cache/my_script/claude_real_usage.json")
    retry = cache + ".retry"  # touched on a failure : no retry every second
    last = None
    try:
        with open(cache) as f:
            last = json.load(f) or None
        if last and time.time() - os.path.getmtime(cache) < 60:
            return last
        if time.time() - os.path.getmtime(retry) < 120 and os.path.getmtime(retry) > os.path.getmtime(cache):
            return still_valid(last)
    except (OSError, ValueError):
        pass
    try:
        with open(os.path.expanduser("~/.claude/.credentials.json")) as f:
            token = json.load(f)["claudeAiOauth"]["accessToken"]
        request = urllib.request.Request("https://api.anthropic.com/api/oauth/usage", headers={
            "Authorization": f"Bearer {token}", "anthropic-beta": "oauth-2025-04-20"})
        with urllib.request.urlopen(request, timeout=5) as response:
            raw = json.load(response)
        data = {k: {"pct": raw[k]["utilization"], "reset": raw[k]["resets_at"]} for k in ("five_hour", "seven_day")}
        os.makedirs(os.path.dirname(cache), exist_ok=True)
        with open(cache, "w") as f:
            json.dump(data, f)
        return data
    except (OSError, ValueError, KeyError, TypeError):
        os.makedirs(os.path.dirname(cache), exist_ok=True)
        with open(retry, "w"):
            pass
        return still_valid(last)


def still_valid(last):
    """The last good value, unless a window already reset since (its % would be wrong then)."""
    if not last:
        return None
    now = datetime.now().astimezone()
    try:
        if all(datetime.fromisoformat(last[k]["reset"]) > now for k in ("five_hour", "seven_day")):
            return last
    except (KeyError, ValueError, TypeError):
        pass
    return None


def reset_in(iso):
    left = datetime.fromisoformat(iso) - datetime.now().astimezone()
    if left.total_seconds() < 0:
        return "0h00"
    if left.days:
        return f"{left.days}d{left.seconds // 3600:02d}h"
    return f"{left.seconds // 3600}h{left.seconds % 3600 // 60:02d}"


ICON = "\uf069"  # asterisk, close to the Claude logo


def emit(bar):
    """waybar json. `short` (the drawer leader) : only the icon ; otherwise the numbers (drawer child)."""
    bar["text"] = ICON if "short" in sys.argv[1:] else bar["text"].removeprefix(ICON).strip()
    print(json.dumps(bar))


def waybar_real(real):
    five, week = real["five_hour"], real["seven_day"]
    pct = max(five["pct"], week["pct"])
    css = "critical" if pct >= 90 else "warning" if pct >= 75 else "active"
    tooltip = "\n".join([
        f"Claude plan usage (real, same as /usage)",
        f"5 h : {five['pct']:.0f}% (reset in {reset_in(five['reset'])})",
        f"Week : {week['pct']:.0f}% (reset in {reset_in(week['reset'])})",
        "Click : the usage report",
    ])
    emit(({"text": f"\uf069 {five['pct']:.0f}% · {week['pct']:.0f}% week · {reset_in(five['reset'])}",
                      "class": css, "tooltip": tooltip}))


def percent(used, key, limits):
    """Estimate, shown with a "~" and capped at 100 (the uncalibrated limits made 124 % appear)."""
    return f"~{min(used / limits[key] * 100, 100):.0f}%" if limits.get(key) else "?%"


def calibrate(pct_block, pct_week):
    """limit = what is used now / the % shown by /usage (the more used at that time, the more exact)."""
    now = datetime.now().astimezone()
    entries = read_entries(now - WEEK)
    _, block = current_block(entries, now)
    limits = load_limits()
    for key, used, pct in (("block", weighted(block), pct_block), ("week", weighted(entries), pct_week)):
        if pct > 0 and used > 0:
            limits[key] = round(used / pct * 100)
    os.makedirs(os.path.dirname(LIMITS), exist_ok=True)
    with open(LIMITS, "w") as f:
        json.dump(limits, f)
    print(f"limits saved in {LIMITS} : {limits}")


def per_model(entries):
    models = defaultdict(lambda: defaultdict(int))
    for _, model, tokens in entries:
        for kind, n in tokens.items():
            models[model][kind] += n
    return models


def model_lines(entries):
    lines = []
    for model, tokens in sorted(per_model(entries).items(), key=lambda m: -total(m[1])):
        lines.append(f"  {model.removeprefix('claude-')} : {human(total(tokens))} "
                     f"(in {human(tokens['input'])}, out {human(tokens['output'])}, "
                     f"cache write {human(tokens['cache_write'])}, cache read {human(tokens['cache_read'])})")
    return lines


def waybar():
    real = real_usage()
    if real:
        return waybar_real(real)
    now = datetime.now().astimezone()
    entries = read_entries(now - WEEK)
    start, block = current_block(entries, now)
    limits = load_limits()
    week = percent(weighted(entries), "week", limits)
    if not block:
        emit(({"text": f"\uf069 - · {week} week", "class": "idle",
                          "tooltip": f"Claude : no message in the last 5 h, week (rolling 7 d) {week}\nClick : the usage report"}))
        return
    left = start + BLOCK - now
    hours, minutes = divmod(int(left.total_seconds()) // 60, 60)
    tokens = sum(total(t) for _, _, t in block)
    output = sum(t["output"] for _, _, t in block)
    tooltip = "\n".join([
        f"Claude, 5 h block {start:%H:%M} → {start + BLOCK:%H:%M} ({hours}h{minutes:02d} left, estimate)",
        f"{len(block)} requests, {human(tokens)} tokens ({human(output)} written by Claude)",
        f"5 h block {percent(weighted(block), 'block', limits)}, week (rolling 7 d) {week} : estimates, "
        "set them right with : my_script claude_usage calibrate <5h %> <week %>",
        *model_lines(block),
        "Real % of the plan : /usage in Claude Code",
        "Click : the usage report",
    ])
    emit(({"text": f"\uf069 {percent(weighted(block), 'block', limits)} · {week} week · {hours}h{minutes:02d}",
                      "class": "active", "tooltip": tooltip}))


def report():
    now = datetime.now().astimezone()
    entries = read_entries(now - timedelta(days=7))
    start, block = current_block(entries, now)
    print("Claude Code usage on this machine (from ~/.claude/projects)\n")
    if block:
        print(f"Current 5 h block, since {start:%H:%M} ({len(block)} requests) :")
        print("\n".join(model_lines(block)))
    else:
        print("No block running (no message in the last 5 h)")
    print("\nLast 7 days :")
    days = defaultdict(list)
    for entry in entries:
        days[entry[0].date()].append(entry)
    for day in sorted(days):
        tokens = sum(total(t) for _, _, t in days[day])
        contexts = [t["input"] + t["cache_read"] + t["cache_write"] for _, _, t in days[day]]
        print(f"{day:%a %d %b} : {len(days[day]):5d} requests, {human(tokens):>7} tokens, context per request "
              f"avg {human(sum(contexts) // len(contexts))} / max {human(max(contexts))}, "
              f"{100 * sum(c > 100_000 for c in contexts) // len(contexts)}% of requests above 100k")
        print("\n".join(model_lines(days[day])))
    print("\nThe % of the plan limits : /usage in Claude Code. Goal : the average context per request goes down.")


if __name__ == "__main__":
    if sys.argv[1:] == ["report"]:
        report()
    elif len(sys.argv) == 4 and sys.argv[1] == "calibrate":
        calibrate(float(sys.argv[2]), float(sys.argv[3]))
    else:
        waybar()
