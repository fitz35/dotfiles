#!/usr/bin/env bash
# `my_script rofi <rofi arguments>` : rofi with a random theme of rofi/themes/ (a different look at each opening),
# e.g. `my_script rofi -show drun` (i3 $mod+d), or `... | my_script rofi -dmenu -p "prompt"` for the menus.

themes=("$MY_SCRIPT_DIR"/rofi/themes/*.rasi)
exec rofi "$@" -config "${themes[RANDOM % ${#themes[@]}]}"
