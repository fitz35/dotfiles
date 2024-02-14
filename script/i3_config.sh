#!/usr/bin/env bash



i3_config_folder="$1/.config/i3"

mkdir -p "$i3_config_folder"

rm -f -- "$i3_config_folder/config_placeholder"
ln "../i3/config_placeholder" "$i3_config_folder/config_placeholder"
rm -f -- "$i3_config_folder/generate_i3_config.sh"
ln "../i3/generate_i3_config.sh" "$i3_config_folder/generate_i3_config.sh"
chmod +x "$i3_config_folder/generate_i3_config.sh"

rm -f -- "$i3_config_folder/screen_management.py"
ln "../i3/screen_management.py" "$i3_config_folder/screen_management.py"

rm -f -- "$i3_config_folder/screen.json"
ln "../i3/screen.json" "$i3_config_folder/screen.json"


cp -n ../i3/i3.env.bk "$i3_config_folder/i3.env"