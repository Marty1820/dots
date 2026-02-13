#!/usr/bin/env bash
# https://github.com/steel99xl/Mac-like-automatic-brightness
# How much light change must be seen by the sensor before it will act
LightChange=10

# How often it checks the sensor
SensorDelay=1

# Scale sensor to display brightness range
# NOW WITH FLOAT SUPPORT
SensorToDisplayScale=1

# 12 steps is the most similar on a Macbook 2017 running Arch compared to MacOS
LevelSteps=12
# Plays the 12 step effectively at 30 FPS 32ms
AnimationDelay=0.032

# Read the variable names
MinimumBrightness=001

# 2 : Default | 1 : Add Offset | 0 : Subtract Offset, Recommended not to change
op=2

# Only look for flags -i or -d with an additional value
# AutomaticBrightness.sh -i 100
while getopts i:d: flag
do
    case "${flag}" in
        i) op=1
           num=${OPTARG};;
        d) op=0 
           num=${OPTARG};;
    esac
done

# Verify offset file exists and if so read it
if [[ -f /dev/shm/AB.offset ]]; then
  OffSet=$(cat /dev/shm/AB.offset)
else
  OffSet=0
  echo $OffSet > /dev/shm/AB.offset
  chmod 666 /dev/shm/AB.offset
fi

# If no offset or its less than 0 make 0
OffSet=$((OffSet < 0 ? 0 : OffSet))

# Relatively change number in Offset file and write it
if [[ $op -lt 2 ]]; then
  if [[ $op -eq 1 ]]; then
    OffSet=$((OffSet + num))
  else 
    OffSet=$((OffSet - num))
  fi
  # Verify offset is not less than 0
  OffSet=$((OffSet < 0 ? 0 : OffSet))
  echo $OffSet > /dev/shm/AB.offset
  exit
fi

# This was moved down here to not affect performance of setting AB.offset
priority=19 # Priority level , 0 = regular app , 19 = very much background app

# Set the priority of the current script, Thank you  Theluga.
renice "$priority" "$$"

sleep 5

# Get screen max brightness value
MaxScreenBrightness=$(find -L /sys/class/backlight -maxdepth 2 -name "max_brightness" 2>/dev/null | grep "max_brightness" | xargs cat)

# Set path to current screen brightness value
BLightPath=$(find -L /sys/class/backlight -maxdepth 2 -name "brightness" 2>/dev/null | grep "brightness")

# Set path to current luminance sensor
LSensorPath=$(find -L /sys/bus/iio/devices -maxdepth 2  -name "in_illuminance_raw" 2>/dev/null | grep "in_illuminance_raw")

# Set the current light value so we have something to compare to
OldSensorLight=$(cat "$LSensorPath")

while true; do
    if [[ -f /dev/shm/AB.offset ]]; then
      OffSet=$(cat /dev/shm/AB.offset)
    else
      OffSet=0
      echo OffSet > /dev/shm/AB.offset
      chmod 666 /dev/shm/AB.offset
    fi

		Light=$(cat "$LSensorPath")
    # Apply offset to current light value
    Light=$((Light + OffSet))

    # Set allowed range for light 
    MaxOld=$((OldSensorLight + OldSensorLight / LightChange))
    MinOld=$((OldSensorLight - OldSensorLight / LightChange))

    if [[ $Light -gt $MaxOld ]] || [[ $Light -lt $MinOld ]]; then
      # Store new light as old light for next comparison
      OldSensorLight=$Light

		  CurrentBrightness=$(cat "$BLightPath")

      # Add MinimumBrightness here to not effect comparison but the outcome
      Light=$(LC_NUMERIC=C printf "%.0f" "$(bc -l <<< "scale=2; $Light + (($MaxScreenBrightness * ($MinimumBrightness / 100 )) / $SensorToDisplayScale )")")
      
      # Generate a TempLight value for the screen to be set to
      # Float math thanks Matthias_Wachter 
      TempLight=$(LC_NUMERIC=C printf "%.0f" "$(bc -l <<< "scale=2; $Light * $SensorToDisplayScale")")

      # Check we do not ask the screen to go brighter than it can
		  if [[ $TempLight -gt $MaxScreenBrightness ]]; then
			  NewBackLight=$MaxScreenBrightness
		  else
			  NewBackLight=$TempLight
		  fi

      # Get new screen brightness as a %
      ScreenPercentage=$(LC_NUMERIC=C printf "%.0f" $(bc -l <<< "scale=2; ( $NewBackLight / $MaxScreenBrightness ) * 100 "))

      # How different should each stop be
      DiffCount=$(LC_NUMERIC=C printf "%.0f" "$(bc -l <<< "scale=2; ($NewBackLight - $CurrentBrightness) / $LevelSteps")")

      # Step once per Screen Hz to make animation
		  for ((i=1; i<=LevelSteps; i++)); do
        CurrentBrightness=$(cat "$BLightPath")
        FakeBackLight=$(( CurrentBrightness + DiffCount ))

        # Clamp to valid range
        if (( FakeBackLight < 0 )); then
          FakeBackLight=0
        elif (( FakeBackLight > MaxScreenBrightness )); then
          FakeBackLight=$MaxScreenBrightness
        fi

        echo "$FakeBackLight" > "$BLightPath"
        # Sleep for the screen Hz time so he effect is visible
			  sleep $AnimationDelay
		  done
    fi
		sleep $SensorDelay
done
