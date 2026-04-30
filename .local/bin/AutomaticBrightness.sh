#!/usr/bin/env bash
# https://github.com/steel99xl/Mac-like-automatic-brightness
# How much light change must be seen by the sensor before it will act
LightChange=10

# How often it checks the sensor
SensorDelay=1

# Scale sensor to display brightness range
# NOW WITH FLOAT SUPPORT
SensorToDisplayScale=0.7

# 12 steps is the most similar on a Macbook 2017 running Arch compared to MacOS
LevelSteps=12
# Plays the 12 step effectively at 30 FPS 32ms
AnimationDelay=0.032

# Read the variable names
MinimumBrightness=1

# 2 : Default | 1 : Add Offset | 0 : Subtract Offset
op=2

# Parse arguments
while getopts i:d: flag; do
  case "${flag}" in
  i)
    op=1
    num=${OPTARG}
    ;;
  d)
    op=0
    num=${OPTARG}
    ;;
  esac
done

# Helper function to write offset safely
write_offset() {
  local val="$1"
  # Ensure file exists and is writable
  if ! [[ -f /dev/shm/AB.offset ]]; then
    touch /dev/shm/AB.offset
    chmod 666 /dev/shm/AB.offset
  fi
  echo "$val" >/dev/shm/AB.offset
}

# Verify offset file exists and if so read it
if [[ -f /dev/shm/AB.offset ]]; then
  OffSet=$(cat /dev/shm/AB.offset)
  # Ensure it's a number
  if ! [[ "$OffSet" =~ ^-?[0-9]+$ ]]; then
    OffSet=0
  fi
else
  OffSet=0
  write_offset "$OffSet"
fi

# If no offset or its less than 0 make 0
if [[ $OffSet -lt 0 ]]; then
  OffSet=0
  write_offset "$OffSet"
fi

# Relatively change number in Offset file and write it
if [[ $op -lt 2 ]]; then
  if [[ $op -eq 1 ]]; then
    OffSet=$((OffSet + num))
  else
    OffSet=$((OffSet - num))
  fi

  # Verify offset is not less than 0
  if [[ $OffSet -lt 0 ]]; then
    OffSet=0
  fi

  write_offset "$OffSet"
  exit 0
fi

# Set process priority (19 = lowest priority)
priority=19
renice "$priority" "$$" >/dev/null 2>&1

sleep 5

# Get screen max brightness value
MaxScreenBrightness=$(find -L /sys/class/backlight -maxdepth 2 -name "max_brightness" 2>/dev/null | head -n1 | xargs cat 2>/dev/null)
if [[ -z "$MaxScreenBrightness" ]] || [[ "$MaxScreenBrightness" -le 0 ]]; then
  echo "Error: Could not find valid screen max_brightness."
  exit 1
fi

# Set path to current screen brightness value
BLightPath=$(find -L /sys/class/backlight -maxdepth 2 -name "brightness" 2>/dev/null | head -n1)
if [[ -z "$BLightPath" ]]; then
  echo "Error: Could not find screen brightness path."
  exit 1
fi

# Set path to current luminance sensor
LSensorPath=$(find -L /sys/bus/iio/devices -maxdepth 2 -name "in_illuminance_raw" 2>/dev/null | head -n1)
if [[ -z "$LSensorPath" ]]; then
  echo "Error: Could not find light sensor path."
  exit 1
fi

# Set the current light value so we have something to compare to
OldSensorLight=$(cat "$LSensorPath" 2>/dev/null)
if [[ -z "$OldSensorLight" ]]; then
  echo "Error: Could not read initial sensor value."
  exit 1
fi

echo "Starting automatic brightness loop..."
echo "Max Screen: $MaxScreenBrightness | Sensor: $LSensorPath | Screen Path: $BLightPath"

while true; do
  # Re-read offset in case it was changed externally
  if [[ -f /dev/shm/AB.offset ]]; then
    OffSet=$(cat /dev/shm/AB.offset)
    if ! [[ "$OffSet" =~ ^-?[0-9]+$ ]]; then OffSet=0; fi
  else
    OffSet=0
    write_offset "$OffSet"
  fi

  Light=$(cat "$LSensorPath" 2>/dev/null)
  if [[ -z "$Light" ]]; then continue; fi

  # Apply offset to current light value
  Light=$((Light + OffSet))

  # Set allowed range for light
  MaxOld=$((OldSensorLight + OldSensorLight / LightChange))
  MinOld=$((OldSensorLight - OldSensorLight / LightChange))

  if [[ $Light -gt $MaxOld ]] || [[ $Light -lt $MinOld ]]; then
    # Store new light as old light for next comparison
    OldSensorLight=$Light

    CurrentBrightness=$(cat "$BLightPath" 2>/dev/null)

    # Add MinimumBrightness here to not effect comparison but the outcome
    # Using bc for float math
    Light=$(printf "%.0f" "$(echo "scale=2; $Light + (($MaxScreenBrightness * ($MinimumBrightness / 100)) / $SensorToDisplayScale)" | bc)")

    # Generate a TempBackLight value for the screen to be set to
    TempBackLight=$(printf "%.0f" "$(echo "scale=2; $Light * $SensorToDisplayScale" | bc)")

    # Check we do not ask the screen to go brighter than it can
    if [[ $TempBackLight -gt $MaxScreenBrightness ]]; then
      NewBackLight=$MaxScreenBrightness
    else
      NewBackLight=$TempBackLight
    fi

    # Get new screen brightness as a %
    ScreenPercentage=$(printf "%.0f" "$(echo "scale=2; ($NewBackLight / $MaxScreenBrightness) * 100" | bc)")

    # How different should each stop be
    DiffCount=$(printf "%.0f" "$(echo "scale=2; ($NewBackLight - $CurrentBrightness) / $LevelSteps" | bc)")

    # Step once per Screen Hz to make animation
    for ((i = 1; i <= LevelSteps; i++)); do
      # Get current screen brightness
      CurrentBrightness=$(cat "$BLightPath" 2>/dev/null)
      if [[ -z "$CurrentBrightness" ]]; then break; fi

      # Accumulate the step correctly
      FakeBackLight=$((CurrentBrightness + DiffCount))

      # Clamp to valid range
      if ((FakeBackLight < 0)); then
        FakeBackLight=0
      elif ((FakeBackLight > MaxScreenBrightness)); then
        FakeBackLight=$MaxScreenBrightness
      fi

      echo "$FakeBackLight" >"$BLightPath"

      # Sleep for the screen Hz time so he effect is visible
      sleep "$AnimationDelay"
    done
  fi

  sleep "$SensorDelay"
done
