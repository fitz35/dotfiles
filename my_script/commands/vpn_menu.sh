#!/usr/bin/env bash
# Rofi menu of the NetworkManager VPN connections (i3 $mod+w) : ● connected, ○ not connected.
# Choosing one connects or disconnects it with nmcli (the password comes from the keyring, or is asked by the
# NetworkManager window of nm-applet), the result is shown in a notification.
# The VPNs are created once with nm-connection-editor (e.g. "vpn inria" : AnyConnect, gateway vpn.inria.fr).

mapfile -t vpns < <(nmcli -t -f NAME,TYPE connection show | awk -F: '$2 == "vpn" || $2 == "wireguard" { print $1 }')
if [ ${#vpns[@]} -eq 0 ]; then
    notify-send "VPN" "No VPN connection in NetworkManager (create one with nm-connection-editor)"
    exit 1
fi
active=$(nmcli -t -f NAME connection show --active)

menu=""
for vpn in "${vpns[@]}"; do
    if grep -qxF "$vpn" <<< "$active"; then
        menu+="● $vpn"$'\n'
    else
        menu+="○ $vpn"$'\n'
    fi
done

choice=$(printf "%s" "$menu" | "$MY_SCRIPT" rofi -dmenu -i -p "VPN")
[ -z "$choice" ] && exit 0
name="${choice#* }"

if [ "${choice%% *}" = "●" ]; then
    action="down"
else
    action="up"
fi

if output=$(nmcli connection "$action" id "$name" 2>&1); then
    [ "$action" = "up" ] && notify-send "VPN" "$name connected" || notify-send "VPN" "$name disconnected"
else
    notify-send -u critical "VPN : $name" "$output"
    exit 1
fi
