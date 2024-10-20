#!/usr/bin/env sh

# Check if a menu name was provided
if [ $# -ne 1 ]; then
  echo "Usage: $0 <menu_name>"
  exit 1
fi

menu_name=$1

# Get the current value
current_value=$(eww get "${menu_name}rev")

# Execute commands based on the current value
if [ "$current_value" = "true" ]; then
    eww update "${menu_name}rev=false" && sleep 1 && eww close "$menu_name" &
else
    eww open "$menu_name" && eww update "${menu_name}rev=true" &
fi
