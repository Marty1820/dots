#!/bin/sh
set -eu

# Folder containing wallpapers/Picking random one
WALLPAPER_DIR="$HOME/Pictures/wallpapers"
SERVICE_NAME="awww-daemon"

# Check if directory exists and is readable
if [ ! -d "$WALLPAPER_DIR" ]; then
  echo "Error: Directory $WALLPAPER_DIR not found" >&2
  exit 1
fi

WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)

if [ -z "$WALLPAPER" ]; then
  echo "Error: No images found in $WALLPAPER_DIR" >&2
  exit 1
fi

if ! pgrep -x $SERVICE_NAME > /dev/null; then
  echo "Starting $SERVICE_NAME..."
  $SERVICE_NAME &
  sleep 0.5
fi

# See awww-img(1)
TYPE="any"
STEPS=90
DURATION=3
FPS=60

echo "Setting wallpaper: $WALLPAPER"
awww img "$WALLPAPER" \
  --transition-type "$TYPE" \
  --transition-step "$STEPS" \
  --transition-duration "$DURATION" \
  --transition-fps "$FPS"
