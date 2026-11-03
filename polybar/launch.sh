#!/usr/bin/env bash

# Terminate already running bar instances, and wait for them to quit
polybar-msg cmd quit > /dev/null 2>&1
for _ in $(seq 25); do
  # on nixos the process is named .polybar-wrapped (truncated to 15 characters)
  pgrep -u "$UID" -x 'polybar|\.polybar-wrappe' > /dev/null || break
  sleep 0.2
done

# ----------------- hardware dependant information (used by config.ini) -----------------
for power_supply in /sys/class/power_supply/*; do
  case "$(cat "$power_supply/type")" in
    Battery) [ -z "$POLYBAR_BATTERY" ] && export POLYBAR_BATTERY="$(basename "$power_supply")" ;;
    Mains) [ -z "$POLYBAR_ADAPTER" ] && export POLYBAR_ADAPTER="$(basename "$power_supply")" ;;
  esac
done

# ---------------------------------------- Launch a bar per screen ----------------------------------------
if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    echo "---" | tee -a /tmp/polybar1.log
    MONITOR=$m polybar bar_1 2>&1 | tee -a /tmp/polybar1.log & disown
  done
else
   echo "---" | tee -a /tmp/polybar1.log
   polybar bar_1 2>&1 | tee -a /tmp/polybar1.log & disown
fi

# toggle the network (not display it)
sleep 2
sh "$HOME/.config/polybar/bar_control/toggle_network.sh"
sh "$HOME/.config/polybar/bar_control/toggle_informations.sh"
sh "$HOME/.config/polybar/bar_control/toggle_time.sh"
sh "$HOME/.config/polybar/bar_control/toggle_spotify.sh"
echo "Bars launched..."
