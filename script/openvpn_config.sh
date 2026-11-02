#!/usr/bin/env bash

repo_dir="$(cd "$(dirname "$0")/.." && pwd)"

openvpn_config_folder="$1.config/openvpn"


# copy the repo files over the existing ones, without removing the folder first :
# the local .env and pass.txt (not versioned) are kept
mkdir -p "$openvpn_config_folder/client"
cp -R "$repo_dir/openvpn/client/." "$openvpn_config_folder/client/"