#!/bin/sh

CONFIG_FILE="$HOME/.local/share/location.toml"

LAT=$(grep '^LAT' "$CONFIG_FILE" | cut -d'"' -f2)
LON=$(grep '^LON' "$CONFIG_FILE" | cut -d'"' -f2)

exec /usr/bin/wlsunset -l "$LAT" -L "$LON"
