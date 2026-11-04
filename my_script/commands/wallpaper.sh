#!/usr/bin/env bash
# Change the wallpaper every INTERVAL seconds, with a random image of the dotfiles assets.
# Started by i3 / sway (exec_always : a sway reload clears the background, the restart sets one at once) and runs
# forever. X (i3) : feh, Wayland (sway) : the sway background.

source "$MY_SCRIPT_DIR/lib.sh"

# one loop only : stop the previous one (started before the reload) ; the exact command line of the loop, so no
# other process mentioning this file (an editor, a shell...) is matched
for pid in $(pgrep -f '^bash [^ ]*/commands/wallpaper\.sh$'); do
    [ "$pid" != "$$" ] && kill "$pid" 2> /dev/null
done

INTERVAL=240 # seconds

while true; do
    if is_wayland; then
        images=("$HOME"/.config/assets/background_image/*)
        swaymsg output '*' bg "${images[RANDOM % ${#images[@]}]}" fill > /dev/null
    else
        feh --bg-fill --randomize "$HOME"/.config/assets/background_image/*
    fi
    sleep "$INTERVAL"
done
