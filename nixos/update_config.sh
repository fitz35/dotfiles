#!/usr/bin/env bash
# build the configuration of this repository and switch to it (the machine is chosen by its hostname)
# WARN : the new files must be added to git (git add), else the flake doesn't see them
# built as the user (root can't read the repository : "not owned by current user"), only the activation uses sudo

nixos-rebuild switch --flake "$(cd "$(dirname "$0")" && pwd)#" --sudo --show-trace
