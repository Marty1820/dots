#!/bin/sh

# Get the brightness level and convert it to a percentage
brightness=$(brightnessctl info | awk -F '[()%]' '/Current/ {print $2}')

notify-send -t 1000 -a 'bk-lit' -h int:value:"$brightness" "Brightness: ${brightness}%"
