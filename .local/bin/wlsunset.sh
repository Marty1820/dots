#!/bin/bash
set -euo pipefail

CONFIG_FILE="$HOME/.config/local_env.toml"

[[ -f "$CONFIG_FILE" ]] || {
  echo "Error: Config file not found at $CONFIG_FILE" >&2
  exit 1
}

# Only works for flat keys, won't handle sections properly
lat=$(grep -E '^LAT\s*=' "$CONFIG_FILE" | head -1 | sed -E 's/.*=\s*"([^"]*)".*/\1/' | tr -d "'")
lon=$(grep -E '^LON\s*=' "$CONFIG_FILE" | head -1 | sed -E 's/.*=\s*"([^"]*)".*/\1/' | tr -d "'")

# Validate
if [[ -z "$lat" || -z "$lon" ]]; then
  echo "Error: Could not parse LAT or LON from $CONFIG_FILE" >&2
  exit 1
fi

# Validate numeric range
if ! [[ "$lat" =~ ^-?[0-9]+\.?[0-9]*$ && "$lon" =~ ^-?[0-9]+\.?[0-9]*$ ]]; then
  echo "Error: LAT and LON must be numeric values" >&2
  exit 1
fi

if (($(echo "$lat < -90 || $lat > 90" | bc -l))); then
  echo "Error: Latitude must be between -90 and 90" >&2
  exit 1
fi

if (($(echo "$lon < -180 || $lon > 180" | bc -l))); then
  echo "Error: Longitude must be between -180 and 180" >&2
  exit 1
fi

echo "Parsed: LAT=$lat, LON=$lon"
exec /usr/bin/wlsunset -l "$lat" -L "$lon"
