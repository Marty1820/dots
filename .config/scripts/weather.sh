#!/usr/bin/env sh

## Data dir
cache_dir="$HOME/.cache/weather"
weather_file="$cache_dir/weatherdata"
weather_forecast="$cache_dir/weatherforecast"
aqi_file="$cache_dir/aqidata"

## Weather data | openweatherdata file first line key second line id
FILE="$HOME/.config/scripts/openweatherdata"
KEY=$(awk 'NR == 1' "$FILE")
LAT=$(awk 'NR == 2' "$FILE")
LON=$(awk 'NR == 3' "$FILE")
UNIT="imperial" # Available options : 'metric' or 'imperial'

## Make cache dir
mkdir -p "$cache_dir"

## Get data
get_weather_data() {
	weather=$(curl -sf "http://api.openweathermap.org/data/2.5/weather?lat=$LAT&lon=$LON&appid=$KEY&units=$UNIT")
	echo "$weather" > "${weather_file}"

	weatherforecast=$(curl -sf "http://api.openweathermap.org/data/2.5/forecast/daily?lat=$LAT&lon=$LON&appid=$KEY&units=$UNIT&cnt=4")
	echo "$weatherforecast" > "${weather_forecast}"
  
  air_polution=$(curl -sf "http://api.openweathermap.org/data/2.5/air_pollution?lat=$LAT&lon=$LON&appid=$KEY")
	echo "$air_polution" > "${aqi_file}"
}

# Pulling info from file
get_jq_value() {
  jq -r "$1" < "$weather_file"
}
get_jq_value_forcast() {
  jq -r "$1" < "$weather_forecast"
}

current_weather() {
  w_temp=$(get_jq_value ".main.temp" | cut -d "." -f 1)
  w_ftemp=$(get_jq_value ".main.feels_like" | cut -d "." -f 1)
  w_stat=$(get_jq_value ".weather[].main" | head -n 1 | sed -e "s/\b\(.\)/\u\1/g")
  w_city=$(get_jq_value ".name")
  w_humid=$(get_jq_value ".main.humidity" | cut -d "." -f 1)
  w_wind=$(get_jq_value ".wind.speed")
  w_clouds=$(get_jq_value ".clouds.all")
}

forecast_weather() {
  day_index=$1
  f_temphigh=$(get_jq_value_forcast ".list[$day_index].temp.max" | cut -d "." -f 1)
  f_templow=$(get_jq_value_forcast ".list[$day_index].temp.min" | cut -d "." -f 1)
  f_srise=$(date -d @"$(get_jq_value_forcast ".list[0].sunrise")" '+%I:%M %p')
  f_sset=$(date -d @"$(get_jq_value_forcast ".list[0].sunset")" '+%I:%M %p')
}

# Set air pollution condition
set_aqi() {
  aqi_number=$(jq -r ".list[].main.aqi" < "$aqi_file")

  case "$aqi_number" in
    1) aqi="Good"; aqi_icon="󰡳"; aqi_color="#50fa7b" ;;
    2) aqi="Fair"; aqi_icon="󰡵"; aqi_color="#f1fa8c" ;;
    3) aqi="Moderate"; aqi_icon="󰊚"; aqi_color="#ffb86c" ;;
    4) aqi="Poor"; aqi_icon="󰡴"; aqi_color="#ff5555" ;;
    5) aqi="Very Poor"; aqi_icon=""; aqi_color="#bd93f9" ;;
    *) aqi="Unknown"; aqi_icon="󰻝"; aqi_color="#ff5555" ;;
  esac
}

# Setting icon and hex values
set_icon() {
	w_icon_code=$(get_jq_value ".weather[].icon" | head -1)

  case "$w_icon_code" in
    01d) w_icon="󰖙"; w_hex="#ffb86c" ;;
    01n) w_icon="󰖔"; w_hex="#bd93f9" ;;
    02d) w_icon="󰖕"; w_hex="#f1fa8c" ;;
    02n) w_icon="󰼱"; w_hex="#6272a4" ;;
    03d|03n|04d|04n) w_icon="󰖐"; w_hex="#bd93f9" ;;
    09d|09n) w_icon="󰖖"; w_hex="#8be9fd" ;;
    10d|10n) w_icon="󰼳"; w_hex="#8be9fd" ;;
    11d) w_icon="󰼲"; w_hex="#ffb86c" ;;
    11n) w_icon="󰖓"; w_hex="#ffb86c" ;;
    13d) w_icon="󰼴"; w_hex="#8be9fd" ;;
    13n) w_icon="󰼶"; w_hex="#8be9fd" ;;
    50d) w_icon="󰼰"; w_hex="#6272a4" ;;
    50n) w_icon="󰖑"; w_hex="#6272a4" ;;
    *) w_icon="󰼯"; w_hex="#ff5555" ;;
  esac
}

case $1 in
  --getdata) get_weather_data ;;
  --icon)	set_icon; echo "$w_icon"	;;
  --hex) set_icon; echo "$w_hex" ;;
  --temp) current_weather; echo "$w_temp" ;;
  --temphigh) forecast_weather "$2"; echo "$f_temphigh" ;;
  --templow) forecast_weather "$2"; echo "$f_templow" ;;
  --feel) current_weather; echo "$w_ftemp" ;;
  --stat) current_weather; echo "$w_stat" ;;
  --city) current_weather; echo "$w_city" ;;
  --humid) current_weather; echo "$w_humid" ;;
  --wind) current_weather; echo "$w_wind" ;;
  --clouds) current_weather; echo "$w_clouds" ;;
  --aqi) set_aqi; echo "$aqi" ;;
  --aqi_color) set_aqi; echo "$aqi_color" ;;
  --aqi_icon) set_aqi; echo "$aqi_icon" ;;
  --srise) forecast_weather; echo "$f_srise" ;;
  --sset) forecast_weather; echo "$f_sset" ;;
  *)
    echo "Usage: $0 {--getdata|--icon|--temp|--temphigh index|--templow index|--feel|--stat|--city|--humid|--wind|--aqi|--aqi_color|--aqi_icon|--srise|--sset}"
    exit 1
    ;;
esac
