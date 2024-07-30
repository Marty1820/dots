#!/usr/bin/env bash

set -eu -o pipefail

STATUS=$(bluetoothctl show | awk '/Powered/ {print $2}')
UUID=$(bluetoothctl devices Connected | cut -f2 -d' ' | head -n1)
if [ "$UUID" = "" ]; then
  DEVICE=""
else
  DEVICE=$(bluetoothctl info "$UUID")
fi

_toggle() {
  if [ "$STATUS" = "yes" ]; then
    bluetoothctl power off
  else
    bluetoothctl power on
  fi
}

_get_battery_percent() {
  ALIAS=$(bluetoothctl info | grep -e "Alias" | cut -f2 -d" ")
  BATTERY_PERCENT=$(echo "$1" |
    grep -e "Battery Percentage" |
    cut -d "(" -f2 |
    cut -d ")" -f1)

  if [ -n "$BATTERY_PERCENT" ]; then
    echo "$ALIAS $BATTERY_PERCENT"
  fi
}

_get_icon() {
  ICON=$(echo "$1" |
    grep -e "Icon" |
    cut -f2- -d" ")

  case $ICON in
  audio-headphones)
    echo "󰥰"
    ;;
  audio-headset)
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
  computer | video-display)
    echo "󰪫"
    ;;
  printer)
    echo "󰐪"
    ;;
  scanner)
    echo "󰚫"
    ;;
  camera-photo | camera-video)
    echo "󰄄"
    ;;
  network-wireless)
    echo "󰂴"
    ;;
  audio-card | multimedia-player)
    echo "󰗾"
    ;;
  modem | unknown)
    echo "󰂱"
    ;;
  *)
    echo ""
    ;;
  esac
}

if [ "$1" = "--toggle" ]; then
  _toggle
elif [ "$1" = "--icon" ]; then
  ICON=$(_get_icon "$DEVICE")
  if [ "$ICON" = "" ]; then
    case $STATUS in
      yes)
        ICON="󰂯"
        ;;
      no | *)
        ICON="󰂲"
    esac
  fi
  echo "$ICON"
elif [ "$1" = "--bat" ]; then
  BATTERY_PERCENT=$(_get_battery_percent "$DEVICE")
  echo "$BATTERY_PERCENT"
fi
