#!/bin/sh

CONFIG_FILE="$HOME/.local/share/location.toml"

awk -F= '
  /^\s*LAT/ {gsub(/[" ]/,"",$2); lat=$2}
  /^\s*LON/ {gsub(/[" ]/,"",$2); lon=$2}
  END {
    if (lat && lon)
      printf "%s %s\n", lat, lon
    else
      exit 1
  }
' "$CONFIG_FILE" |
{
  read -r lat lon || exit 1
  exec /usr/bin/wlsunset -l "$lat" -L "$lon"
}
