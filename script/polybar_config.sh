#!/usr/bin/env bash

repo_dir="$(cd "$(dirname "$0")/.." && pwd)"

polybar_config_folder="$1.config/polybar"

rm -rf -- "$polybar_config_folder"

mkdir -p "$polybar_config_folder"

ln -sf "$repo_dir/polybar/config_placeholder.ini" "$polybar_config_folder/config_placeholder.ini"
ln -sf "$repo_dir/polybar/launch.sh" "$polybar_config_folder/launch.sh"

cp -r "$repo_dir/polybar/bluetooth/" "$polybar_config_folder/bluetooth/"

cp -r "$repo_dir/polybar/spotify/" "$polybar_config_folder/spotify/"
chmod +x "$polybar_config_folder/spotify/get_spotify_status.sh"
chmod +x "$polybar_config_folder/spotify/scroll_spotify_status.sh"
chmod +x "$polybar_config_folder/spotify/pipewire.sh"

# -------------- bar_control --------------

mkdir -p "$polybar_config_folder/bar_control"
source_folder="$repo_dir/polybar/bar_control"
target_folder="$polybar_config_folder/bar_control"

# Iterate through the files in the source folder and create symbolic links
for file in "$source_folder"/*; do
    if [ -f "$file" ]; then
        ln -sf "$file" "$target_folder/$(basename "$file")"
    fi
done
