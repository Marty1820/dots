#!/usr/bin/env bash

# Function to get WiFi signal and ESSID
get_wifi_info() {
  local signal
  local essid

  signal=$(nmcli -f in-use,signal dev wifi | awk '/\*/ {print $2}')
  essid=$(nmcli -t -f NAME connection show --active | head -n1 | sed 's/"/\\"/g')

  echo "{\"essid\": \"$essid\", \"signal\": \"$signal\"}"
}

# Initial output
get_wifi_info

# Monitor link changes
ip monitor link | while read -r _; do
  get_wifi_info
done
