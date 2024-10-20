#!/usr/bin/env sh

# Check if a menu name was provided
if [ $# -ne 1 ]; then
  echo "Usage: $0 <menu_name>"
  exit 1
fi

menu_name=$1

# Get the current value
current_value=$(eww get "${menu_name}rev")

# Determine the new value for revealer
if [ "$current_value" = "true" ] || [ -z "$current_value" ]; then
  new_value="false"
else
  new_value="true"
fi

# Execute commands based on the current value
if [ "$current_value" = "true" ]; then
    eww update "${menu_name}rev=$new_value" && sleep 1 && eww open --toggle "$menu_name" &
else
    eww open --toggle "$menu_name" && eww update "${menu_name}rev=$new_value" &
fi
