#!/usr/bin/env bash
# Frees the / partition (the nix store is on it), asking before each step.
# Usage : my_script clean [-y]   (opened in a terminal by a click on the waybar disk alert)
#   -y : answer yes to every step, no question and no pause at the end (for a cron / systemd timer ; the sudo
#   steps then need root or a sudo without password). Weekly automatic cleaning of nix, docker and the journal
#   is already done by nixos/modules/services.nix : this script is for the deeper manual clean.
# Steps : old system and user generations (the last 3 kept), the direnv shells of the projects untouched for
# 30 days (rebuilt at the next cd), nix garbage collection, docker unused images and build cache, the journal,
# then the boot menu is regenerated without the deleted generations.

auto=false
[ "${1:-}" = "-y" ] || [ "${1:-}" = "--yes" ] && auto=true

ask() {
    $auto && return 0
    read -r -p "$1 [y/N] " answer
    [ "$answer" = "y" ] || [ "$answer" = "Y" ]
}

usage() { df -h / | awk 'NR == 2 { print "/ : " $3 " used of " $2 ", " $4 " free (" $5 ")" }'; }

echo "Before : $(usage)"
echo

echo "System generations :"
sudo nix-env -p /nix/var/nix/profiles/system --list-generations | tail -n 8
if ask "Delete the system generations, except the last 3 ?"; then
    sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +3
    nix-env --delete-generations +3
fi
echo

# the direnv shells pin their whole dev environment in the store (gcroots in /nix/var/nix/gcroots/auto)
mapfile -t idle < <(find "$HOME/Documents/github" -maxdepth 4 -type d -name .direnv -prune -mtime +30 2>/dev/null)
if [ "${#idle[@]}" -gt 0 ]; then
    echo "direnv shells of the projects untouched for 30 days :"
    printf '  %s\n' "${idle[@]%/.direnv}"
    if ask "Delete them ?"; then
        rm -rf "${idle[@]}"
    fi
    echo
fi

if ask "Collect the nix garbage ?"; then
    sudo nix-collect-garbage
    # the boot menu still lists the deleted generations until it is regenerated
    sudo /run/current-system/bin/switch-to-configuration boot
fi
echo

if command -v docker > /dev/null && ask "Remove the unused docker images and build cache ?"; then
    docker image prune -a -f
    docker builder prune -f
fi
echo

if ask "Shrink the journal to 200 MB ?"; then
    sudo journalctl --vacuum-size=200M
fi

echo
echo "After : $(usage)"
$auto || read -r -p "Press Enter to close"
