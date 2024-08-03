#!/usr/bin/env sh

# Script name that controls screen brightness
bright_script="screen_brightness.sh"

# Process ID of script
bright_PID=$(pgrep -f "$bright_script")

# Check if the process is running
if [ -z "$bright_PID" ]; then
  echo "Process $bright_script not found"
  exit 1
fi

# Status of process STOP/CONT
bright_status=$(ps -o state= -p "$bright_PID")

# Get backlight percent
cur_backlight=$(xbacklight -get | awk '{print int($1)}')

bright_toggle() {
  case "$bright_status" in
    S) kill -STOP "$bright_PID" ;;
    T) kill -CONT "$bright_PID" ;;
    *) echo "Unknown process state: $bright_status" ;;
  esac
}

bright_icon() {
  case "$bright_status" in
    S) echo "󰃡" ;;
    T)
      if [ "$cur_backlight" -lt 25 ]; then
        echo "󰃝"
      elif [ "$cur_backlight" -lt 50 ]; then
        echo "󰃞"
      elif [ "$cur_backlight" -lt 75 ]; then
        echo "󰃟"
      else
        echo "󰃠"
      fi
      ;;
  esac
}

case "$1" in
  --toggle) bright_toggle ;;
  --icon)   bright_icon ;;
  *) echo "Usage: $0 --toggle | --icon" ;;
esac
