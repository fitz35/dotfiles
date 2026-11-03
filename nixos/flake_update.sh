#!/usr/bin/env bash
# update the flake inputs (nixpkgs, minegrub, my_script) in flake.lock, then apply them with update_config.sh

nix flake update --flake "$(cd "$(dirname "$0")" && pwd)"
