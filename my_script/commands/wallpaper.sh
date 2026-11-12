#!/usr/bin/env bash
# Change the wallpaper every INTERVAL seconds, with a random image of the dotfiles assets.
# Started by i3 / sway (exec_always : a sway reload clears the background, the restart sets one at once) and runs
# forever. X (i3) : feh, Wayland (sway) : the sway background.

source "$MY_SCRIPT_DIR/lib.sh"

# one loop only : stop the previous one (started before the reload) ; the exact command line of the loop, so no
# other process mentioning this file (an editor, a shell...) is matched
for pid in $(pgrep -f '^bash [^ ]*/commands/wallpaper\.sh$'); do
    [ "$pid" != "$$" ] && kill "$pid" 2> /dev/null
done

INTERVAL=240 # seconds

while true; do
    # the files of the subfolders too (private/ : the git-ignored images, kept out of the public repo) ; -L : the
    # assets folder is a link into the dotfiles
    mapfile -t images < <(find -L "$HOME/.config/assets/background_image" -type f)
    if [ "${#images[@]}" -gt 0 ]; then
        image="${images[RANDOM % ${#images[@]}]}"
        if is_wayland; then
            swaymsg output '*' bg "$image" fill > /dev/null
        else
            feh --bg-fill "$image"
        fi
    fi
    sleep "$INTERVAL"
done
