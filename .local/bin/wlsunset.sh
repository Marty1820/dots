#!/bin/sh

CONFIG_FILE="$HOME/.local/share/location.toml"

LAT=$(awk -F= '/^\s*LAT/ {gsub(/[" ]/,"",$2); print $2;exit}' "$CONFIG_FILE")
LON=$(awk -F= '/^\s*LON/ {gsub(/[" ]/,"",$2); print $2;exit}' "$CONFIG_FILE")

exec /usr/bin/wlsunset -l "$LAT" -L "$LON"
