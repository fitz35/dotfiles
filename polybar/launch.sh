#!/usr/bin/env bash

# Terminate already running bar instances
# If all your bars have ipc enabled, you can use 
polybar-msg cmd quit
# Otherwise you can use the nuclear option:
# killall -q polybar

# ----------------- regenerate the polybar config with relevant information -----------------
# generate the config file
polybar_config_folder="$HOME/.config/polybar"
original_config_path="${polybar_config_folder}/config_placeholder.ini"
modified_config_path="${polybar_config_folder}/config.ini"

cp "$original_config_path" "$modified_config_path"

# get informations
battery_infos=($(ls -1 /sys/class/power_supply/))
adpater=${battery_infos[0]}
battery=${battery_infos[1]}

# replace the placeholders
sed -i "s|&BATTERY_HARDWARE&|${battery}|g" "$modified_config_path"
sed -i "s|&ADAPTER_HARDWARE&|${adpater}|g" "$modified_config_path"

sed -i "s|%PLACEHOLDER_CONFIG_FOLDER%|${polybar_config_folder}|g" "$modified_config_path"

# ---------------------------------------- Launch bar1 and bar2 ----------------------------------------
if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    echo "---" | tee -a /tmp/polybar1.log /tmp/polybar2.log
    MONITOR=$m polybar bar_1 2>&1 | tee -a /tmp/polybar1.log & disown
  done
else
   echo "---" | tee -a /tmp/polybar1.log /tmp/polybar2.log
   polybar bar_1 2>&1 | tee -a /tmp/polybar1.log & disown
fi

# toggle the network (not display it)
sleep 2
sh "$HOME/.config/polybar/bar_control/toggle_network.sh"
sh "$HOME/.config/polybar/bar_control/toggle_informations.sh"
sh "$HOME/.config/polybar/bar_control/toggle_time.sh"
sh "$HOME/.config/polybar/bar_control/toggle_spotify.sh"
echo "Bars launched..."

