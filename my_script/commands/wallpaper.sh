#!/usr/bin/env bash
# Change the wallpaper every INTERVAL seconds, with a random image of the dotfiles assets.
# Started once by i3 / sway at login and runs forever. X (i3) : feh, Wayland (sway) : the sway background.

source "$MY_SCRIPT_DIR/lib.sh"

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
