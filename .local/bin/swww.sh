#!/bin/sh

# Folder containing wallpapers/Picking random one
WALLPAPER_DIR="$HOME/Pictures/wallpapers"
WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)

# See swww-img(1)
TYPE="any"
STEPS=90
DURATION=3
FPS=60

swww img "$WALLPAPER" \
  --transition-type "$TYPE" \
  --transition-step "$STEPS" \
  --transition-duration "$DURATION" \
  --transition-fps "$FPS"
