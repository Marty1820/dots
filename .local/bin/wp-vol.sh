#!/bin/sh

# Get the volume level and convert it to a percentage
volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf "%d", $2 * 100}')

notify-send -t 1000 -a 'wp-vol' -h int:value:"$volume" "Volume: ${volume}%"
