# Global notes for Claude Code (every project)

Linked as `~/.claude/CLAUDE.md` by the dotfiles' `install.sh`.

## Token hygiene
Every message re-sends the whole conversation : the cost of a message grows with the session.
- When a task is finished or the topic changes, propose opening a new agent window; first write a 3–5 line handoff
  the user can paste into the new session (or save it to memory / the project's todo).
- The Stop hook `context_reminder.py` warns above 100k tokens of context : finish the step, then
  propose opening a new agent window (with a handoff).
- Large files : `grep -n '^#'` (or a targeted grep) first, then Read only the needed section
  (offset/limit). Don't re-read a file already in context.
- Filter long command outputs (`2>&1 | tail -n 40`, `grep -E 'error|warning|test result'`). Run
  long commands in the background with their output in a file, then read only its end.
- Memory files hold the *current state* in a few lines, not a diary : the history belongs in git
  and the todo files.
- Answer concisely, without restating what is already established.

## Sub-agents
- Use `Explore` only for wide searches across many folders; ask it for file paths, not dumps.
- A sub-agent must return a short summary (the few lines that matter), never the raw output.
