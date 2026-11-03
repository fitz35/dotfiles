#!/usr/bin/env bash
# Change the wallpaper every INTERVAL seconds, with a random image of the dotfiles assets.
# Started once by i3 at login and runs forever.

INTERVAL=240 # seconds

while true; do
    feh --bg-fill --randomize "$HOME"/.config/assets/background_image/*
    sleep "$INTERVAL"
done
