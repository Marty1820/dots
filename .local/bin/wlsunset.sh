#!/usr/bin/env bash
set -euo pipefail
# pacman -S jq

CONFIG_FILE="$HOME/.config/local_env.json"

[[ -f "$CONFIG_FILE" ]] || {
  echo "Error: Config file not found at $CONFIG_FILE" >&2
  exit 1
}

if ! command -v jq >>/dev/null 2>&1; then
  echo "Error: jq is required but not installed" >&2
  exit 1
fi

lat=$(jq -r '.wlsunset.lat // empty' "$CONFIG_FILE")
lon=$(jq -r '.wlsunset.lon // empty' "$CONFIG_FILE")

# Validate extraction
if [[ -z "$lat" || -z "$lon" ]]; then
  echo "Error: Could not parse LAT or LON from $CONFIG_FILE" >&2
  exit 1
fi

# Validate numeric format
if ! [[ "$lat" =~ ^-?[0-9]+\.?[0-9]*$ && "$lon" =~ ^-?[0-9]+\.?[0-9]*$ ]]; then
  echo "Error: LAT and LON must be numeric values" >&2
  exit 1
fi

# Validate ranges
awk "BEGIN{exit !($lat >= -90 && $lat <= 90)}" || {
  echo "Error: Latitude must be between -90 and 90" >&2
  exit 1
}

awk "BEGIN{exit !($lon >= -180 && $lon <= 180)}" || {
  echo "Error: Longitude must be between -180 and 180" >&2
  exit 1
}

echo "Parsed: LAT=$lat, LON=$lon"
exec /usr/bin/wlsunset -l "$lat" -L "$lon"
