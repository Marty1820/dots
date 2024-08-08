#!/usr/bin/env sh

# Function to get current volume
get_volume() {
  pamixer --get-volume-human | tr -d '%'
}

# Print the initial volume
get_volume

# Monitor for volume changes
pactl subscribe | while read -r line; do
  if echo "$line" | grep -q "Event 'change' on sink"; then
    get_volume
  fi
done
