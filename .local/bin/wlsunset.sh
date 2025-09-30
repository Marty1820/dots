#!/bin/sh

CONFIG_FILE="$HOME/.local/share/location.toml"

set -- $(awk -F= '
  /^\s*LAT/ {gsub(/[" ]/,"",$2); lat=$2}
  /^\s*LON/ {gsub(/[" ]/,"",$2); lon=$2; print lat, lon; exit}
' "$CONFIG_FILE")

exec /usr/bin/wlsunset -l "$1" -L "$2"
