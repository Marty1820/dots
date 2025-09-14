#!/bin/sh

# Get the volume level and convert it to a percentage
volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf "%d", $2 * 100}')

notify-send --app-name="wp-vol" --urgency low --expire-time=1000 --hint=int:value:"$volume" "Volume: ${volume}%"
