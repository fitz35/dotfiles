#!/usr/bin/env bash
# build the configuration of this repository and switch to it (the machine is chosen by its hostname)
# WARN : the new files must be added to git (git add), else the flake doesn't see them

sudo nixos-rebuild switch --flake "$(cd "$(dirname "$0")" && pwd)#" --show-trace
