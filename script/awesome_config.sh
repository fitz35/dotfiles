#!/usr/bin/env bash

repo_dir="$(cd "$(dirname "$0")/.." && pwd)"

awesome_folder="$1.config/awesome"


mkdir -p "$awesome_folder"
ln -sf "$repo_dir/awesome_wm/rc.lua" "$awesome_folder/rc.lua"
ln -sf "$repo_dir/awesome_wm/theme.lua" "$awesome_folder/theme.lua"
rm -f -- "$awesome_folder/shared_tags.lua"
cp "$repo_dir/awesome_wm/shared_tags.lua" "$awesome_folder/shared_tags.lua"
