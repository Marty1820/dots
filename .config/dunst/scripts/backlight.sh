#!/usr/bin/env sh

# Dependancies 'xorg-xbacklight' or 'acpilight' & 'dunst'
# You can call this script like this:
# $./backlight.sh up
# $./backlight.sh down

# Gets brightness percent from 'xbacklight'
get_backlight() {
  xbacklight -get | awk '{print int($1)}'
}

# Determines the percent increase/decrease based on current brightness & direction
set_curve() {
  local backlight direction percent
	backlight=$(get_backlight)
  direction="$1"

	if [ "$direction" = up ]; then
		if [ "$backlight" -lt 10 ]; then
			percent=1
		elif [ "$backlight" -lt 50 ]; then
			percent=5
		else
			percent=10
		fi
	else
		if [ "$backlight" -le 10 ]; then
			percent=1
		elif [ "$backlight" -le 50 ]; then
			percent=5
		else
			percent=10
		fi
	fi

  echo "$percent"
}

# Sends notification with dunst and sets progress bar
send_notification() {
  local backlight icon bar
  backlight=$(get_backlight)
  icon="/usr/share/icons/dracula-icons/16/panel/gpm-brightness-lcd.svg"

  # Generate progress bar
  bar=$(seq -s "─" 0 $((backlight / 5)) | sed 's/[0-9]//g')

  # Send the notification
  dunstify -i "$icon" --timeout=1600 --replace=2593 --urgency=normal "$backlight    $bar"
}

case $1 in
up)
  percent=$(set_curve "up")
  xbacklight -inc "$percent" >/dev/null
  send_notification
  ;;
down)
  percent=$(set_curve "down")
  xbacklight -dec "$percent" >/dev/null
  send_notification
  ;;
esac
