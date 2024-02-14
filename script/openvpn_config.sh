#!/usr/bin/env bash

openvpn_config_folder="$1.config/openvpn"


mkdir -p "$openvpn_config_folder"
rm -Rf "$openvpn_config_folder/client"
cp -R ../openvpn/client "$openvpn_config_folder/client"