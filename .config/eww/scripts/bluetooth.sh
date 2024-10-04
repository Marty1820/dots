#!/usr/bin/env bash
set -eu -o pipefail

# Get Bluetooth status and connected device UUID
STATUS=$(bluetoothctl show | awk '/Powered/ {print $2}')
UUID=$(bluetoothctl devices Connected | awk '{print $2}' | head -n1)
DEVICE=""

if [ -n "$UUID" ]; then
  DEVICE=$(bluetoothctl info "$UUID")
fi

# Toggle Bluetooth power
toggle() {
  if [ "$STATUS" = "yes" ]; then
    bluetoothctl power off
  else
    bluetoothctl power on
  fi
}

# Get device alias from the info
get_device_info() {
  echo "$1" | awk -F ': ' '/Alias/ {print $2}'
}

# Get battery percentage from the info
get_battery_percent() {
  echo "$1" | awk -F '[()]' '/Battery Percentage/ {print $2}'
}

# Get device icon based on its type
get_icon() {
  local icon
  icon=$(echo "$1" | awk -F ': ' '/Icon/ {print $2}')

  case $icon in
  audio-headphones|audio-headset) echo "󰥰" ;;
  input-gaming) echo "" ;;
  input-keyboard) echo "󰌌" ;;
  input-mouse) echo "󰦋" ;;
  input-tablet) echo "󰓷" ;;
  phone) echo "󰏳" ;;
  computer|video-d y) echo "󰪫" ;;
  pinter) echo "󰐪" ;;
  scanner) echo "󰚫" ;;
  camera-photo|camera-video) echo "󰄄" ;;
  network-wireless) echo "󰂴" ;;
  audio-card|multimedia-player) echo "󰗾" ;;
  modem|unknown) echo "󰂱" ;;
  *) echo "" ;;
  esac
}

# Handle script arguments
case $1 in
  --toggle) toggle ;;
  --icon)
    ICON=$(get_icon "$DEVICE")
    [ -z "$ICON" ] && ICON=$([ "$STATUS" = "yes" ] && echo "󰂯" || echo "󰂲")
    echo "$ICON"
    ;;
  --bat)
    BATTERY_PERCENT=$(get_battery_percent "$DEVICE")
    echo "$BATTERY_PERCENT"
    ;;
  --info)
    INFO=$(get_device_info "$DEVICE")
    echo "$INFO"
    ;;
  *)
    echo "Usage: $0 {--toggle|--icon|--bat|--info}"
    exit 1
    ;;
esac
