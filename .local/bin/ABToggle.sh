#!/bin/sh
set -eu

SERVICE="AB.service"

# Ensure you're in a graphical session
if [ -z "${DISPLAY:-}" ] && [ -z "${WAYLAND_DISPLAY:-}" ]; then
  echo "Error: No graphical session detected" >&2
  exit 1
fi

if systemctl --user is-active --quiet "$SERVICE"; then
  systemctl --user stop "$SERVICE"
  notify-send -t 1000 -a 'bk-lit' "Adaptive Brightness off" || true
else
  systemctl --user start "$SERVICE"
  notify-send -t 1000 -a 'bk-lit' "Adaptive Brightness on" || true
fi
