#!/bin/bash

# Set default values
default_current_now=1
default_voltage_now=1

# Check if the files exist and read their values, otherwise use default values
if [ -f /sys/class/power_supply/BAT0/current_now ]; then
    current_now=$(cat /sys/class/power_supply/BAT0/current_now)
else
    current_now=$default_current_now
fi

if [ -f /sys/class/power_supply/BAT0/voltage_now ]; then
    voltage_now=$(cat /sys/class/power_supply/BAT0/voltage_now)
else
    voltage_now=$default_voltage_now
fi

# Use awk to calculate the product and convert to watts
echo "$current_now $voltage_now" | awk 'BEGIN {sum=1} {sum*=$1; sum*=$2} END {print sum*1e-12 " W"}'
