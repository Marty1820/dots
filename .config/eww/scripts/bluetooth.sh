#!/usr/bin/env bash

set -eu -o pipefail

# Get Bluetooth status and connected device UUID
STATUS=$(bluetoothctl show | awk '/Powered/ {print $2}')
UUID=$(bluetoothctl devices Connected | awk '{print $2}' | head -n1)
DEVICE=""

if [ -n "$UUID" ]; then
  DEVICE=$(bluetoothctl info "$UUID")
fi

_toggle() {
  if [ "$STATUS" = "yes" ]; then
    bluetoothctl power off
  else
    bluetoothctl power on
  fi
}

_get_device_info() {
  echo "$1" | awk -F ': ' '/Alias/ {print $2}'
}

_get_battery_percent() {
  echo "$1" | awk -F '[()]' '/Battery Percentage/ {print $2}'
}

_get_icon() {
  ICON=$(echo "$1" | awk -F ': ' '/Icon/ {print $2}')

  case $ICON in
  audio-headphones|audio-headset)
    echo "󰥰"
    ;;
  input-gaming)
    echo ""
    ;;
  input-keyboard)
    echo "󰌌"
    ;;
  input-mouse)
    echo "󰦋"
    ;;
  input-tablet)
    echo "󰓷"
    ;;
  phone)
    echo "󰏳"
    ;;
  computer|video-display)
    echo "󰪫"
    ;;
  printer)
    echo "󰐪"
    ;;
  scanner)
    echo "󰚫"
    ;;
  camera-photo|camera-video)
    echo "󰄄"
    ;;
  network-wireless)
    echo "󰂴"
    ;;
  audio-card|multimedia-player)
    echo "󰗾"
    ;;
  modem|unknown)
    echo "󰂱"
    ;;
  *) echo "" ;;
  esac
}

# Handle script arguments
case $1 in
  --toggle)
    _toggle
    ;;
  --icon)
    ICON=$(_get_icon "$DEVICE")
    if [ -z "$ICON" ]; then
      ICON=$([ "$STATUS" = "yes" ] && echo "󰂯" || echo "󰂲")
    fi
    echo "$ICON"
    ;;
  --bat)
    BATTERY_PERCENT=$(_get_battery_percent "$DEVICE")
    echo "$BATTERY_PERCENT"
    ;;
  --info)
    INFO=$(_get_device_info "$DEVICE")
    echo "$INFO"
    ;;
  *)
    echo "Usage: $0 {--toggle|--icon|--bat|--info}"
    exit 1
    ;;
esac
