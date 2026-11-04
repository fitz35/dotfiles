# Claude Code token usage, read from the local logs (~/.claude/projects/*/*.jsonl), like ccusage does.
# Usage : my_script claude_usage          : waybar json (the tokens of the current 5 h block and its time left)
#         my_script claude_usage report   : the current block and the last 7 days, per model (in a terminal)
# Only the sessions of this machine are counted, and the % of the plan limits (shown by /usage in Claude Code)
# isn't in the logs : the block here is an estimate (5 h from its first message, as the reset time shown by /usage).
import glob
import json
import os
import sys
import time
from collections import defaultdict
from datetime import datetime, timedelta

BLOCK = timedelta(hours=5)
PROJECTS = os.path.expanduser("~/.claude/projects")


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
    now = datetime.now().astimezone()
    start, block = current_block(read_entries(now - BLOCK * 2), now)
    if not block:
        print(json.dumps({"text": "󰚛 -", "class": "idle",
                          "tooltip": "Claude : no message in the last 5 h\nClick : the usage report"}))
        return
    left = start + BLOCK - now
    hours, minutes = divmod(int(left.total_seconds()) // 60, 60)
    tokens = sum(total(t) for _, _, t in block)
    output = sum(t["output"] for _, _, t in block)
    tooltip = "\n".join([
        f"Claude, 5 h block {start:%H:%M} → {start + BLOCK:%H:%M} ({hours}h{minutes:02d} left, estimate)",
        f"{len(block)} requests, {human(tokens)} tokens ({human(output)} written by Claude)",
        *model_lines(block),
        "Real % of the plan : /usage in Claude Code",
        "Click : the usage report",
    ])
    print(json.dumps({"text": f"󰚛 {human(output)} · {hours}h{minutes:02d}",
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
        print(f"{day:%a %d %b} : {len(days[day]):5d} requests, {human(tokens):>7} tokens")
        print("\n".join(model_lines(days[day])))
    print("\nThe % of the plan limits : /usage in Claude Code. Tip : /clear between tasks.")


if __name__ == "__main__":
    if sys.argv[1:] == ["report"]:
        report()
    else:
        waybar()
