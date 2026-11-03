#!/usr/bin/env bash
# Link the dotfiles of this repository in the home directory (the system itself is installed by nixos/).
# Can be run again at any time (after adding a file for example) : it doesn't change what is already linked.
# The links point to the repository, so they work on every OS using this /home (nixos and the fedora fallback).
set -e

repo_dir="$(cd "$(dirname "$0")" && pwd)"

# link <path in the repository> <target> : an existing file or folder (not a link) is kept as <target>.bak
link() {
    local source="$repo_dir/$1"
    local target="$2"
    mkdir -p "$(dirname "$target")"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        if [ -e "$target.bak" ]; then
            echo "Error: $target exists and $target.bak too, move one of them first"
            exit 1
        fi
        echo "keep the existing $target as $target.bak"
        mv "$target" "$target.bak"
    fi
    ln -sfn "$source" "$target"
}

# window manager, bar and screens (autorandr profiles + the postswitch hook updating i3)
link i3 "$HOME/.config/i3"
link i3/autorandr "$HOME/.config/autorandr"
link polybar "$HOME/.config/polybar"

# wallpapers (used by my_script wallpaper)
link assets "$HOME/.config/assets"

link greenclip/greenclip.toml "$HOME/.config/greenclip.toml"
link dunst/dunstrc "$HOME/.config/dunst/dunstrc"

for font in "$repo_dir"/fonts/*.ttf; do
    link "fonts/$(basename "$font")" "$HOME/.fonts/$(basename "$font")"
done

# copied, not linked : the local ssh config keeps the private hosts that aren't in the repository
mkdir -p "$HOME/.ssh"
cp -n "$repo_dir/ssh/config" "$HOME/.ssh/config"

echo "Dotfiles linked"
