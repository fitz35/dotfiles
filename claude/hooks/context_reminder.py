# Claude Code Stop hook : after each reply, remind me to open a new agent window when the context gets large.
# Every message re-sends the whole conversation, so the cost of a message grows with the session.
# Input (stdin) : the hook json, with `transcript_path` (the session's jsonl).
# Output : {"systemMessage": ...} above the thresholds (shown under the reply), nothing below.
# It always exits 0 : a bug here must never block a session.
import json
import os
import sys

WARN = 100_000    # tokens : finish the step, then open a new agent window
URGENT = 150_000  # tokens : new agent window now
TAIL = 2 * 1024 * 1024  # bytes read from the end of the transcript (the files reach 15 MB)


def context_tokens(path):
    """Context size of the last main-thread reply (input + cache write + cache read), None if not found."""
    size = os.path.getsize(path)
    with open(path, "rb") as f:
        f.seek(max(0, size - TAIL))
        lines = f.read().decode("utf-8", errors="replace").splitlines()
    # the first line may be cut by the seek : it fails to parse and is skipped
    for line in reversed(lines):
        if '"usage"' not in line:
            continue
        try:
            entry = json.loads(line)
            if entry.get("isSidechain") or entry.get("type") != "assistant":
                continue  # subagents have their own context
            usage = entry["message"]["usage"]
        except (ValueError, KeyError, TypeError):
            continue
        return (usage.get("input_tokens", 0)
                + usage.get("cache_creation_input_tokens", 0)
                + usage.get("cache_read_input_tokens", 0))
    return None


def main():
    try:
        path = json.load(sys.stdin).get("transcript_path")
        tokens = context_tokens(os.path.expanduser(path)) if path else None
    except Exception:
        return
    if tokens is None or tokens < WARN:
        return
    k = round(tokens / 1000)
    if tokens >= URGENT:
        message = f"Context at {k}k tokens : write a short handoff, then open a new agent window now"
    else:
        message = f"Context at {k}k tokens : finish the step, then open a new agent window"
    print(json.dumps({"systemMessage": message}))


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass
    sys.exit(0)
