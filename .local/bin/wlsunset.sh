#!/bin/bash
set -euo pipefail

CONFIG_FILE="$HOME/.config/local_env.json"

[[ -f "$CONFIG_FILE" ]] || {
  echo "Error: Config file not found at $CONFIG_FILE" >&2
  exit 1
}

if ! command -v jq >>/dev/null 2>&1; then
  echo "Error: jq is required but not installed" >&2
  exit 1
fi

lat=$(jq -r '.coords.lat // empty' "$CONFIG_FILE")
lon=$(jq -r '.coords.lon // empty' "$CONFIG_FILE")

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

if awk "BEGIN{exit !($lat >= -90 && $lat <= 90)}"; then :; else
  echo "Error: Latitude must be between -90 and 90" >&2
  exit 1
fi

if awk "BEGIN{exit !($lon >= -180 && $lat <= 180)}"; then :; else
  echo "Error: Longitude must be between -180 and 180" >&2
  exit 1
fi

echo "Parsed: LAT=$lat, LON=$lon"
exec /usr/bin/wlsunset -l "$lat" -L "$lon"
