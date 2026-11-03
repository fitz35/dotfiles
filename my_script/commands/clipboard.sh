#!/usr/bin/env bash
# Clipboard history (i3 / sway $mod+v) : choose an entry of the history in rofi, then paste it in the active window.
# X (i3) : the greenclip daemon (services.greenclip in the nixos config), pasted with xdotool.
# Wayland (sway) : cliphist (fed by `wl-paste --watch cliphist store` in the sway config), pasted with wtype.

source "$MY_SCRIPT_DIR/lib.sh"

if is_wayland; then
    SELECTION=$(cliphist list | "$MY_SCRIPT" rofi -dmenu -p "clipboard")
    [ -z "$SELECTION" ] && exit 0
    cliphist decode <<< "$SELECTION" | wl-copy
    # rofi is closed, the focus is back on the window
    wtype -M shift -k Insert -m shift
    exit 0
fi

# get the window id of the active window to paste into
WINDOW_ID=$(xdotool getactivewindow)
"$MY_SCRIPT" rofi -modi "clipboard:greenclip print" -show clipboard -run-command '{cmd}'
sleep 0.5

# Capture the selection
TEXT="$( xclip -o -selection clipboard )"

# Only attempt to paste if there has been selection
if [ "${TEXT}x" != "x" ]; then
    # xdotool type "$TEXT"
    xdotool windowactivate --sync $WINDOW_ID
    xdotool key --clearmodifiers Shift+Insert
fi
