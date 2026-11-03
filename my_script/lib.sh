#!/usr/bin/env bash
# Helpers shared by the commands (loaded with `source "$MY_SCRIPT_DIR/lib.sh"`)

# Print a number of seconds as MM:SS (used by the chronometer and timer polybar modules)
format_time() {
    local elapsed="$1"
    local minutes=$((elapsed / 60))
    local seconds=$((elapsed % 60))
    printf "%02d:%02d" "$minutes" "$seconds"
}

# true in a Wayland session (sway), false in X (i3)
is_wayland() {
    [ -n "$WAYLAND_DISPLAY" ]
}

# i3-msg in i3, swaymsg in sway (same commands)
wm_msg() {
    if is_wayland; then
        swaymsg "$@"
    else
        i3-msg "$@"
    fi
}
