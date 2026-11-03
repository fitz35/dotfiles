#!/usr/bin/env bash
# Clipboard history (i3 $mod+v) : choose an entry of the greenclip history in rofi, then paste it in the active window.
# Needs the greenclip daemon (services.greenclip in the nixos config).

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