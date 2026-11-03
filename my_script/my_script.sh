#!/usr/bin/env bash
# Entry point, installed as `my_script` by default.nix (wrapped with the runtime dependencies in the PATH).
# Usage : my_script <command> [arguments] : runs commands/<command>.sh or commands/<command>.py.
# The commands call the other ones through $MY_SCRIPT (e.g. `"$MY_SCRIPT" rofi -dmenu ...`).

MY_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export MY_SCRIPT_DIR
export MY_SCRIPT="$MY_SCRIPT_DIR/my_script.sh"

command="$1"
shift

if [ -f "$MY_SCRIPT_DIR/commands/$command.sh" ]; then
    exec bash "$MY_SCRIPT_DIR/commands/$command.sh" "$@"
elif [ -f "$MY_SCRIPT_DIR/commands/$command.py" ]; then
    exec python3 "$MY_SCRIPT_DIR/commands/$command.py" "$@"
fi

echo "Usage : my_script <command> [arguments]"
echo "Commands : $(cd "$MY_SCRIPT_DIR/commands" && ls | sed 's/\.[a-z]*$//' | tr '\n' ' ')"
[ -n "$command" ] && echo "Error : unknown command '$command'"
exit 1
