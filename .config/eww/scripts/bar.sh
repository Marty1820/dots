#!/usr/bin/env sh

eww open bar

prev_numwin=0

while true; do
  numwin=$(hyprctl activeworkspace | sed -n 's/.*windows: \([0-9]*\).*/\1/p')

  if [ "$numwin" -ne "$prev_numwin" ]; then
    case "$numwin" in
      0) eww update eww-bar-color="transparent" ;;
      1) eww update eww-bar-color="rgba(30, 31, 41, 230)" ;;
      *) eww update eww-bar-color="linear-gradient(180deg, rgba(30, 31, 41, 230), transparent)" ;;
    esac
    prev_numwin=$numwin
  fi

  sleep 0.5
done
