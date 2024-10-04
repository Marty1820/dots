#!/usr/bin/env sh

directory=~/Pictures/wallpapers
monitor=$(hyprctl monitors | awk '/Monitor/ {print $2}')

# Check if the directory exists and is a directory
if [ -d "$directory" ]; then
  # Find a random file in the directory
  random_background=$(find $directory -type f | shuf -n 1)

  # Unload and reload wallpapers
  hyprctl hyprpaper unload all
  hyprctl hyprpaper preload "$random_background"
  hyprctl hyprpaper wallpaper "$monitor, $random_background"
fi
