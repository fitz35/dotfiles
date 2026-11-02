#!/usr/bin/env bash

repo_dir="$(cd "$(dirname "$0")/.." && pwd)"

home_manager_folder="$1.config/home-manager"


mkdir -p "$home_manager_folder"

ln -sf "$repo_dir/home_manager/home.nix" "$home_manager_folder/home.nix"

ln -sf "$repo_dir/home_manager/flake.nix" "$home_manager_folder/flake.nix"


cp -n "$repo_dir/home_manager/config.nix" "$home_manager_folder/config.nix"
