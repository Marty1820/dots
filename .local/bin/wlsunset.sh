#!/bin/bash

CONFIG_FILE="$HOME/.local/share/location.toml"

# Only works for flat keys, won't handle sections properly
lat=$(grep '^LAT\s*=' "$CONFIG_FILE" | head -1 | sed -E 's/.*=\s*"([^"]*)".*/\1/')
lon=$(grep '^LON\s*=' "$CONFIG_FILE" | head -1 | sed -E 's/.*=\s*"([^"]*)".*/\1/')

# Validate
if [[ -z "$lat" || -z "$lon" ]]; then
  echo "Error: Could not parse LAT or LON from $CONFIG_FILE" >&2
  exit 1
fi

echo "Parsed: LAT=$lat, LON=$lon"

exec /usr/bin/wlsunset -l "$lat" -L "$lon"
