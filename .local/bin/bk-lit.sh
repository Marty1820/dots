#!/bin/sh

# Get the brightness level and convert it to a percentage
brightness=$(brightnessctl info | awk -F '[()%]' '/Current/ {print $2}')

notify-send --app-name="bk-lit" --urgency low --expire-time=1000 --hint=int:value:"$brightness" "Brightness: ${brightness}%"
