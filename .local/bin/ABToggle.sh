#!/bin/sh

service="AB.service"

if systemctl --user is-active --quiet "$service"; then
  systemctl --user stop "$service"
  notify-send -t 1000 -a 'AB' "Adaptive Brightness off"
else
  systemctl --user start "$service"
  notify-send -t 1000 -a 'AB' "Adaptive Brightness on"
fi
