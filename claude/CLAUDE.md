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

## Python scripts
Zed checks Python with basedpyright (strict-ish "standard" + its own extra rules) and Ruff : write code
that is clean for both, the system Python is 3.13.
- Types : builtin generics and `|` unions (`list[str]`, `dict[str, int]`, `tuple[int, ...]`, `str | None`),
  never `typing.List/Dict/Tuple/Optional/Union`. `Callable`, `Iterable`, `Iterator` come from `collections.abc`.
- Annotate every parameter and return type, `-> None` included, and give empty containers a type
  (`items: list[str] = []`) : unannotated code makes basedpyright spread "Unknown" everywhere.
- Never bare `list` / `dict` in annotations : always with their type arguments.
- JSON (`json.load`, `swaymsg`, API answers) is `Any` : describe its shape with a `TypedDict` and `cast` it
  once where it is read, so the `Any` stops there instead of flowing through the script.
- `Optional` narrowing : if a value can be `None`, test it (`if start is None: return`) before using it ;
  testing another variable that "goes with it" doesn't narrow it.
- `subprocess.run(..., check=True|False)` always explicit ; no `os.popen` / `os.system`. Ignored results :
  `_ = f()` only when basedpyright flags them (`reportUnusedCallResult`).
- `with open(...)`, `sys.exit()` (not `exit()`), catch the precise exception (`OSError`, `json.JSONDecodeError`,
  `KeyError`), never `except Exception: pass`. No implicit string concatenation inside a list.
- Before finishing, check the edited files (Zed's own binaries, nothing to install) :
  `~/.local/share/zed/languages/ruff/ruff-*/ruff-*/ruff check <files>` and
  `~/.local/share/zed/node/node-*/bin/node ~/.local/share/zed/languages/basedpyright/node_modules/basedpyright/index.js <files>`
  (paths change with Zed updates : `ls` them if they fail).
