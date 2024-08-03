#!/usr/bin/env sh

# Function to get current volume
get_volume() {
  pamixer --get-volume-human | tr -d '%'
}

# Print the initial volume
get_volume

# Monitor for volume changes
pactl subscribe | awk '/on sink/ {system("get_volume")}' | while read -r _; do
  get_volume
done
