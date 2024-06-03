#!/usr/bin/env sh

## Data dir
cache_dir="$HOME/.cache/weather"
weather_file="$cache_dir/weatherdata"
aqi_file="$cache_dir/aqidata"

## Weather data | openweatherdata file first line key second line id
FILE="$HOME/.config/scripts/openweatherdata"
KEY=$(awk 'NR == 1' "$FILE")
LAT=$(awk 'NR == 2' "$FILE")
LON=$(awk 'NR == 3' "$FILE")
UNIT="imperial" # Available options : 'metric' or 'imperial'

## Make cache dir
if [ ! -d "$cache_dir" ]; then
	mkdir -p "${cache_dir}"
fi

## Get data
get_weather_data() {
	weather=$(curl -sf "http://api.openweathermap.org/data/2.5/weather?lat=$LAT&lon=$LON&appid=$KEY&units=$UNIT")
	echo "$weather" >"${weather_file}"
  air_polution=$(curl -sf "http://api.openweathermap.org/data/2.5/air_pollution?lat=$LAT&lon=$LON&appid=$KEY")
	echo "$air_polution" >"${aqi_file}"
}

# Pulling info from file
w_temp=$(jq ".main.temp" <"$weather_file" | cut -d "." -f 1)
w_ftemp=$(jq ".main.feels_like" <"$weather_file" | cut -d "." -f 1)
w_stat=$(jq -r ".weather[].description" <"$weather_file" | head -1 | sed -e "s/\b\(.\)/\u\1/g")
w_city=$(jq -r ".name" <"$weather_file" | head -1)
w_humid=$(jq -r ".main.humidity" <"$weather_file" | cut -d "." -f 1)
w_wind=$(jq -r ".wind" <"$weather_file" | cut -d ":" -f 2 -s | head -1 | sed 's/.$//')

# Set air pollution condition
set_aqi() {
  aqi=$(jq -r ".list[].main" <"$aqi_file" | cut -d ":" -f 2 -s | xargs)

  if [ "$aqi" = "1" ]; then
    aqi="Good"
    aqi_color="#f8f8f2"
  elif [ "$aqi" = "2" ]; then
    aqi="Fair"
    aqi_color="#f8f8f2"
  elif [ "$aqi" = "3" ]; then
    aqi="Moderate"
    aqi_color="#ffb86c"
  elif [ "$aqi" = "4" ]; then
    aqi="Poor"
    aqi_color="#ff5555"
  elif [ "aqi" = "5" ]; then
    aqi="Very Poor"
    aqi_color="#ff5555"
  fi  
}

# Setting icon and hex values
set_icon() {
	w_icon_code=$(jq -r ".weather[].icon" <"$weather_file" | head -1)

	#Big long if statement of doom
	if [ "$w_icon_code" = "01d" ]; then
		w_icon="󰖙"
		w_hex="#ffb86c"
	elif [ "$w_icon_code" = "01n" ]; then
		w_icon="󰖔"
		w_hex="#bd93f9"
	elif [ "$w_icon_code" = "02d" ]; then
		w_icon="󰖕"
		w_hex="#f1fa8c"
	elif [ "$w_icon_code" = "02n" ]; then
		w_icon="󰼱"
		w_hex="#6272a4"
	elif [ "$w_icon_code" = "03d" ] || [ "$w_icon_code" = "03n" ] || [ "$w_icon_code" = "04d" ] || [ "$w_icon_code" = "04n" ]; then
		w_icon="󰖐"
		w_hex="#bd93f9"
	elif [ "$w_icon_code" = "09d" ] || [ "$w_icon_code" = "09n" ]; then
		w_icon="󰖖"
		w_hex="#8be9fd"
	elif [ "$w_icon_code" = "10d" ] || [ "$w_icon_code" = "10n" ]; then
		w_icon="󰼳"
		w_hex="#8be9fd"
	elif [ "$w_icon_code" = "11d" ]; then
		w_icon="󰼲"
		w_hex="#ffb86c"
	elif [ "$w_icon_code" = "11n" ]; then
		w_icon="󰖓"
		w_hex="#ffb86c"
	elif [ "$w_icon_code" = "13d" ]; then
		w_icon="󰼴"
		w_hex="#8be9fd"
	elif [ "$w_icon_code" = "13n" ]; then
		w_icon="󰼶"
		w_hex="#8be9fd"
	elif [ "$w_icon_code" = "50d" ]; then
		w_icon="󰼰"
		w_hex="#6272a4"
	elif [ "$w_icon_code" = "50n" ]; then
		w_icon="󰖑"
		w_hex="#6272a4"
	else
		w_icon="󰼯"
		w_hex="#ff5555"
	fi
}

case $1 in
--getdata)
	get_weather_data
	;;
--icon)
	set_icon
	echo "$w_icon"
	;;
--hex)
	set_icon
	echo "$w_hex"
	;;
--temp)
	echo "$w_temp"
	;;
--feel)
	echo "$w_ftemp"
	;;
--stat)
	echo "$w_stat"
	;;
--city)
	echo "$w_city"
	;;
--humid)
	echo "$w_humid"
	;;
--wind)
	echo "$w_wind"
	;;
--aqi)
  set_aqi
  echo "$aqi"
  ;;
--aqi_color)
  set_aqi
  echo "$aqi_color"
  ;;
--waybar)
	set_icon
	printf "{\"text\":\"<span foreground=\\\\\"%s\\\\\">%s</span> %s\", \"alt\":\"%s\", \"tooltip\":\"Real feel: %s\"}\n" "$w_hex" "$w_icon" "$w_temp" "$w_stat" "$w_ftemp"
	;;
esac
