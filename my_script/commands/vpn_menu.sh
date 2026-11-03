#!/usr/bin/env bash
# Rofi menu of the VPNs (i3 / sway $mod+w) : ● connected, ○ not connected. Choosing one connects or disconnects it,
# the result is shown in a notification.
# - the NetworkManager VPN connections, with nmcli (the password comes from the keyring, or is asked by the
#   NetworkManager window of nm-applet) ; created once with nm-connection-editor (e.g. "vpn inria" : AnyConnect, vpn.inria.fr)
# - tailscale (services.tailscale), with tailscale up / down : no sudo, the user is the tailscale operator (nixos config)

TAILSCALE="tailscale"

menu=""

# NetworkManager
mapfile -t vpns < <(nmcli -t -f NAME,TYPE connection show | awk -F: '$2 == "vpn" || $2 == "wireguard" { print $1 }')
active=$(nmcli -t -f NAME connection show --active)
for vpn in "${vpns[@]}"; do
    if grep -qxF "$vpn" <<< "$active"; then
        menu+="● $vpn"$'\n'
    else
        menu+="○ $vpn"$'\n'
    fi
done

# tailscale (only if its daemon answers)
if tailscale_state=$(tailscale status --json 2>/dev/null | python3 -c 'import json,sys; print(json.load(sys.stdin)["BackendState"])' 2>/dev/null); then
    if [ "$tailscale_state" = "Running" ]; then
        menu+="● $TAILSCALE"$'\n'
    else
        menu+="○ $TAILSCALE"$'\n'
    fi
fi

if [ -z "$menu" ]; then
    notify-send "VPN" "No VPN (create one with nm-connection-editor)"
    exit 1
fi

choice=$(printf "%s" "$menu" | "$MY_SCRIPT" rofi -dmenu -i -p "VPN")
[ -z "$choice" ] && exit 0
name="${choice#* }"

if [ "${choice%% *}" = "●" ]; then
    action="down"
else
    action="up"
fi

if [ "$name" = "$TAILSCALE" ]; then
    # when the login expired, `tailscale up` prints the URL to open : it is shown in the notification
    output=$(timeout 30 tailscale "$action" 2>&1)
else
    output=$(nmcli connection "$action" id "$name" 2>&1)
fi
status=$?
# nmcli only says "successfully activated (D-Bus path...)" : keep its output for the errors
[ $status -eq 0 ] && [ "$name" != "$TAILSCALE" ] && output=""

if [ $status -eq 0 ]; then
    [ "$action" = "up" ] && message="$name connected" || message="$name disconnected"
    notify-send "VPN" "$message${output:+$'\n'$output}"
else
    notify-send -u critical "VPN : $name" "$output"
    exit 1
fi
