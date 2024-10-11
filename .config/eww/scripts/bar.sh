#!/usr/bin/env sh

eww open bar

prev_numwin=0

while true; do
  numwin=$(hyprctl activeworkspace | awk '/windows:/ {print $2}')

  if [ "$numwin" -ne "$prev_numwin" ]; then
    if [ "$numwin" -eq 0 ]; then
      eww update eww-bar-color="transparent"
    elif [ "$numwin" -eq 1 ]; then
      eww update eww-bar-color="rgba(30, 31, 41, 230)"
    else
      eww update eww-bar-color="linear-gradient(180deg, rgba(30, 31, 41, 230), transparent)"
    fi
    prev_numwin=$numwin
  fi

  sleep .5
done
