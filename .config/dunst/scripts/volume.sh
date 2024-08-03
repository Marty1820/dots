#!/usr/bin/env sh

# Dependancies 'pamixer' & 'dunst'
# Usage:
# $./volume.sh up
# $./volume.sh down
# $./volume.sh mute

# Icons
vol_high=/usr/share/icons/dracula-icons/16/panel/audio-volume-high.svg
vol_med=/usr/share/icons/dracula-icons/16/panel/audio-volume-medium.svg
vol_low=/usr/share/icons/dracula-icons/16/panel/audio-volume-low.svg
vol_mute=/usr/share/icons/dracula-icons/16/panel/audio-volume-muted.svg

# Gets volume percent without the '%' sign
get_volume() {
	pamixer --get-volume
}

# Checks if volume is muted
is_mute() {
  pamixer --get-mute | grep -q 'true'
}

send_notification() {
  local volume
	volume=$(get_volume)
  local icon

  # Select the appropriate icon and create the progress bar
  if is_mute; then
    icon="$vol_mute"
    bar=""
    notification_text="Mute"
  elif [ "$volume" -eq 0 ]; then
    icon="$vol_mute"
    bar=""
    notification_text="$volume"
  elif [ "$volume" -lt 30 ]; then
    icon="$vol_low"
    notification_text="$volume"
  elif [ "$volume" -lt 80 ]; then
    icon="$vol_high"
    notification_text="$volume"
  else
    icon="$vol_high"
    notification_text="$volume"
  fi

  # Generate progress bar
  local bar
  bar=$(seq -s "─" 0 $((volume / 5)) | sed 's/[0-9]//g')
	# Send the notification
  dunstify -i "$icon" --timeout=1600 --replace=2593 --urgency=normal "$notification_text $bar"
}

case "$1" in
  up)
    pamixer -u -i 1
    send_notification
    ;;
  down)
    pamixer -u -d 1
    send_notification
    ;;
  mute)
    pamixer -t
    if is_mute; then
      dunstify -i "$vol_mute" --timeout=1600 --replace=2593 --urgency=normal "Mute" -h string:x-dunst-stack-tag:volume
    else
      send_notification
    fi
    ;;
esac
