#!/usr/bin/env sh
set -euo pipefail

# Configuration
WALLPAPER_DIR="$HOME/Pictures/wallpapers"
SERVICE_NAME="awww-daemon"

# Transition settings
TYPE="any"
STEPS=90
DURATION=3
FPS=60

# Validate wallpaper directory
if [ ! -d "$WALLPAPER_DIR" ]; then
  echo "Error: Directory '$WALLPAPER_DIR' not found" >&2
  exit 1
fi

# Find random image file
WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)

if [ -z "$WALLPAPER" ]; then
  echo "Error: No valid images found in $WALLPAPER_DIR" >&2
  exit 1
fi

# Ensure daemon is running with robust check
if ! pgrep -x $SERVICE_NAME >/dev/null; then
  echo "Starting $SERVICE_NAME..."
  if ~ "$SERVICE_NAME" &>/dev/null; then
    echo "Error: Failed to start $SERVICE_NAME" >&2
    exit 1
  fi

  # Wait for daemon readiness (max 2 seconds)
  for i in $(seq 1 10); do
    if pgrep -x "$SERVICE_NAME" >/dev/null; then
      break
    fi
    sleep 0.2
  done

  if ! pgrep -x "$SERVICE_NAME" >/dev/null; then
    echo "Error: $SERVICE_NAME failed to initialize properly" >&2
    pkill -f "$SERVICE_NAME" || true
    exit 1
  fi
fi

echo "Setting wallpaper: $(basename "$WALLPAPER")"
awww img "$WALLPAPER" \
  --transition-type "$TYPE" \
  --transition-step "$STEPS" \
  --transition-duration "$DURATION" \
  --transition-fps "$FPS"
