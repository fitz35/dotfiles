#!/usr/bin/env bash


polybar_config_folder="$1/.config/polybar"

rm -rf -- "$polybar_config_folder"

mkdir -p "$polybar_config_folder"

ln "../polybar/config_placeholder.ini" "$polybar_config_folder/config_placeholder.ini"
ln "../polybar/launch.sh" "$polybar_config_folder/launch.sh"

cp -r ../polybar/bluetooth/ "$polybar_config_folder/bluetooth/"

cp -r ../polybar/spotify/ "$polybar_config_folder/spotify/"
chmod +x "$polybar_config_folder/spotify/get_spotify_status.sh"
chmod +x "$polybar_config_folder/spotify/scroll_spotify_status.sh"
chmod +x "$polybar_config_folder/spotify/pipewire.sh"

# -------------- bar_control --------------

mkdir -p "$polybar_config_folder/bar_control"
source_folder="../polybar/bar_control"
target_folder="$polybar_config_folder/bar_control"

# Iterate through the files in the source folder and create symbolic links
for file in "$source_folder"/*; do
    if [ -f "$file" ]; then
        ln "$file" "$target_folder/$(basename "$file")"
    fi
done

