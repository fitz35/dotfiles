#!/usr/bin/env bash




i3_config_folder="$HOME/.config/i3"



original_config_path="${i3_config_folder}/config_placeholder"
modified_config_path="${i3_config_folder}/config"

screen_script_path="${i3_config_folder}/screen_management.py"

# run the screen management script (after the autorandr service has been started)
python3 "$screen_script_path"
cp "$original_config_path" "$modified_config_path"

source "$i3_config_folder/i3.env"
env_variable=(
    "MY_SCRYPT"
    "I3_TOUCHPAD_ID"
    "I3_TOUCHPAD_NATURAL_SCROLLING"
    
    "SCREEN_1"
    "SCREEN_2"
    "SCREEN_3"
)

# Check if the environment variables are set
for var in "${env_variable[@]}"; do
    if [ -z "${!var}" ]; then
        echo "Error: $var environment variable is not set in i3.env."
        exit 1
    fi
done

# Generate the placeholders list based on environment variables
placeholders=()
for var in "${env_variable[@]}"; do
    placeholders+=("&PLACEHOLDER_$var&")
done

# Replace the placeholders in the config file
for ((i = 0; i < ${#env_variable[@]}; i++)); do
    sed -i "s|${placeholders[i]}|${!env_variable[$i]}|g" "$modified_config_path"
done