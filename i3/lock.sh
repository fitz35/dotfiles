#!/bin/sh
# This script is a wrapper for i3lock-color
# It sets the colors and options for i3lock-color
# i3lock-color repo: https://github.com/Raymo111/i3lock-color

# Define color variables
BACKGROUND_WINDOW_DARK="#1c2128"
BACKGROUND_WINDOW_NORMAL="#22272e"
BACKGROUND_WINDOW_LIGHT="#2d333b"

TEXT_NORMAL="#adbac7"
TEXT_BRIGHT="#dcdcdc"

YELLOW="#f0b746"
ORANGE="#ff8700"
RED="#d7005f"
GREEN="#00af87"
BLUE="#5f87ff"
CYAN="#00afff"

# Convert colors to format that i3lock-color expects
# Append 'ff' to make colors fully opaque
BACKGROUND_WINDOW_DARK="${BACKGROUND_WINDOW_DARK}ff"
BACKGROUND_WINDOW_NORMAL="${BACKGROUND_WINDOW_NORMAL}ff"
BACKGROUND_WINDOW_LIGHT="${BACKGROUND_WINDOW_LIGHT}ff"
TEXT_NORMAL="${TEXT_NORMAL}ff"
TEXT_BRIGHT="${TEXT_BRIGHT}ff"
YELLOW="${YELLOW}ff"
ORANGE="${ORANGE}ff"
RED="${RED}ff"
GREEN="${GREEN}ff"
BLUE="${BLUE}ff"
CYAN="${CYAN}ff"

# Run i3lock-color with the specified colors
i3lock --color=$BACKGROUND_WINDOW_DARK --inside-color=$BACKGROUND_WINDOW_NORMAL \
       --insidever-color=$ORANGE --ringver-color=$YELLOW \
       --insidewrong-color=$RED --ringwrong-color=$RED \
       --inside-color=$BACKGROUND_WINDOW_DARK --ring-color=$GREEN \
       --line-uses-inside \
       --keyhl-color=$ORANGE --bshl-color=$CYAN \
       --separator-color=$BACKGROUND_WINDOW_NORMAL \
       --verif-color=$TEXT_NORMAL --wrong-color=$TEXT_NORMAL --layout-color=$TEXT_NORMAL \
       --date-color=$TEXT_BRIGHT --time-color=$TEXT_BRIGHT \
       --screen 1 --clock --indicator \
       --date-str="%A, %m %Y" --time-size=48 --date-size=24 \
       --radius=200 \
      --time-font="JetBrains Mono Nerd Font" --date-font="JetBrains Mono Nerd Font" \
       --layout-font="JetBrains Mono Nerd Font" --verif-font="JetBrains Mono Nerd Font" \
       --wrong-font="JetBrains Mono Nerd Font"