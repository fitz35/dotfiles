#!/usr/bin/env bash

# autorandr hook, run after each screen switch (when a screen is plugged / unplugged)
# regenerate the i3 config with the new screens, reload i3 (that relaunch the polybar too),
# then move the open workspaces to their screen (i3 only assigns a screen to the new workspaces)

# at login, i3 isn't started yet and the config is generated before it (see the nixos configuration)
i3-msg -t get_version > /dev/null 2>&1 || exit 0

sh "$HOME/.config/i3/generate_i3_config.sh"
i3-msg reload
python3 "$HOME/.config/i3/rearrange_workspaces.py"
