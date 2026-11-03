#!/usr/bin/env bash

repo_dir="$(cd "$(dirname "$0")/.." && pwd)"

i3_config_folder="$1.config/i3"

mkdir -p "$i3_config_folder"

ln -sf "$repo_dir/i3/config_placeholder" "$i3_config_folder/config_placeholder"
ln -sf "$repo_dir/i3/generate_i3_config.sh" "$i3_config_folder/generate_i3_config.sh"
chmod +x "$repo_dir/i3/generate_i3_config.sh"

ln -sf "$repo_dir/i3/screen_management.py" "$i3_config_folder/screen_management.py"

ln -sf "$repo_dir/i3/screen.json" "$i3_config_folder/screen.json"

ln -sf "$repo_dir/i3/rearrange_workspaces.py" "$i3_config_folder/rearrange_workspaces.py"

# regenerate the i3 config when autorandr switch the screens
autorandr_config_folder="$1.config/autorandr"
mkdir -p "$autorandr_config_folder"
ln -sf "$repo_dir/i3/autorandr_postswitch.sh" "$autorandr_config_folder/postswitch"
chmod +x "$repo_dir/i3/autorandr_postswitch.sh"


cp -n "$repo_dir/i3/i3.env.bk" "$i3_config_folder/i3.env"
