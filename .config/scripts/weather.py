#!/usr/bin/env python3

import os
import requests
import json
import sys
from datetime import datetime

# Define paths
home = os.path.expanduser("~")
# openweatherdata file Example:
# API_KEY='your_api_key_here'
# LAT='latitude_value_here'
# LON='longitude_value_here'
# UNITS='units_value_here'  # e.g., 'metric' or 'imperial'
api_file_path = os.path.join(home, ".config", "scripts", "openweatherdata")
cache_dir = os.path.join(home, ".cache", "weather")
onecall_file = os.path.join(cache_dir, "onecall.json")
aqi_file = os.path.join(cache_dir, "aqidata.json")


# Read API credentials and parameters from a key-value configuration file
def load_api_config(file_path):
    config = {}
    with open(file_path, "r") as file:
        for line in file:
            key, value = line.strip().split("=", 1)
            value = value.strip("'")  # Remove any surrounding quotes
            config[key] = value
    return config


api_config = load_api_config(api_file_path)
API_KEY = api_config.get("API_KEY")
LAT = api_config.get("LAT")
LON = api_config.get("LON")
UNITS = api_config.get("UNITS", "imperial")  # Default to 'imperial' if not specified

# Ensure cache directory exists
os.makedirs(cache_dir, exist_ok=True)


def fetch_data(url, params):
    try:
        response = requests.get(url, params=params)
        response.raise_for_status()
        return response.json()
    except requests.RequestException as e:
        print(f"Error fetching data: {e}")
        sys.exit(1)


def get_weather_data():
    base_url = "http://api.openweathermap.org/data/"
    urls = {
        "onecall": base_url + "3.0/onecall?",
        "air_pollution": base_url + "2.5/air_pollution?",
    }
    params = {
        "appid": API_KEY,
        "lat": LAT,
        "lon": LON,
        "units": UNITS,
    }

    data = {key: fetch_data(url, params) for key, url in urls.items()}

    with open(onecall_file, "w") as f:
        json.dump(data["onecall"], f, indent=4)
    with open(aqi_file, "w") as f:
        json.dump(data["air_pollution"], f, indent=4)

    print("Data successfully fetched and saved.")


def load_json(file_path):
    with open(file_path, "r") as f:
        return json.load(f)


def get_jq_value(data, query):
    keys = query.strip(".").split(".")
    for key in keys:
        if isinstance(data, list):
            key = int(key) if key.isdigit() else key
            if key < len(data):
                data = data[key]
            else:
                return None
        elif isinstance(data, dict):
            key = int(key) if key.isdigit() else key
            data = data.get(key, None)
            if data is None:
                return None
        else:
            return None
    return data


def onecall_weather(day_index=0):
    data = load_json(onecall_file)
    # Format the day_index corrrectly in the strings
    temp_high_query = f".daily.{day_index}.temp.max"
    temp_low_query = f".daily.{day_index}.temp.min"
    sunrise_query = f".daily.{day_index}.sunrise"
    sunset_query = f".daily.{day_index}.sunset"

    sunrise_timestamp = get_jq_value(data, sunrise_query)
    sunset_timestamp = get_jq_value(data, sunset_query)

    return {
        "temp": get_jq_value(data, ".current.temp"),
        "feels_like": get_jq_value(data, ".current.feels_like"),
        "status": get_jq_value(data, ".current.weather.0.main"),
        "humidity": get_jq_value(data, ".current.humidity"),
        "wind_speed": get_jq_value(data, ".current.wind_speed"),
        "clouds": get_jq_value(data, ".current.clouds"),
        "icon": get_jq_value(data, ".current.weather.0.icon"),
        "temphigh": get_jq_value(data, temp_high_query),
        "templow": get_jq_value(data, temp_low_query),
        "sunrise": (
            datetime.fromtimestamp(sunrise_timestamp).strftime("%I:%M %p")
            if isinstance(sunrise_timestamp, (int, float))
            else None
        ),
        "sunset": (
            datetime.fromtimestamp(sunset_timestamp).strftime("%I:%M %p")
            if isinstance(sunset_timestamp, (int, float))
            else None
        ),
    }


def set_aqi():
    data = load_json(aqi_file)
    aqi_data = get_jq_value(data, ".list.0.main.aqi")

    # Ensure aqi_data is a valid integer or use a default value if it's None
    if aqi_data is None:
        aqi_data = -1  # Use -1 or any other value not in aqi_dict

    aqi_dict = {
        1: ("Good", "󰡳", "#50fa7b"),
        2: ("Fair", "󰡵", "#f1fa8c"),
        3: ("Moderate", "󰊚", "#ffb86c"),
        4: ("Poor", "󰡴", "#ff5555"),
        5: ("Very Poor", "", "#bd93f9"),
    }
    return aqi_dict.get(aqi_data, ("Unknown", "󰻝", "#ff5555"))


def set_icon():
    icon_map = {
        "01d": ("󰖙", "#ffb86c"),
        "01n": ("󰖔", "#bd93f9"),
        "02d": ("󰖕", "#f1fa8c"),
        "02n": ("󰼱", "#6272a4"),
        "03d": ("󰖐", "#bd93f9"),
        "03n": ("󰖐", "#bd93f9"),
        "04d": ("󰖐", "#bd93f9"),
        "04n": ("󰖐", "#bd93f9"),
        "09d": ("󰖖", "#8be9fd"),
        "09n": ("󰖖", "#8be9fd"),
        "10d": ("󰼳", "#8be9fd"),
        "10n": ("󰼳", "#8be9fd"),
        "11d": ("󰼲", "#ffb86c"),
        "11n": ("󰖓", "#ffb86c"),
        "13d": ("󰼴", "#8be9fd"),
        "13n": ("󰼶", "#8be9fd"),
        "50d": ("󰼰", "#6272a4"),
        "50n": ("󰖑", "#6272a4"),
    }
    icon_code = onecall_weather()["icon"]
    return icon_map.get(icon_code, ("󰼯", "#ff5555"))


def main():
    if len(sys.argv) < 2:
        print(
            "Usage: script.py {--getdata|--icon|--temp|--temphigh index|--templow index|--feel|--stat|--humid|--wind|--aqi|--aqi_color|--aqi_icon|--srise|--sset}"
        )
        sys.exit(1)

    option = sys.argv[1]

    if option == "--getdata":
        get_weather_data()
    elif option == "--icon":
        print(set_icon()[0])
    elif option == "--hex":
        print(set_icon()[1])
    elif option == "--temp":
        print(onecall_weather()["temp"])
    elif option == "--temphigh":
        if len(sys.argv) < 3:
            print("Index required for --temphigh")
            sys.exit(1)
        print(onecall_weather(int(sys.argv[2]))["temphigh"])
    elif option == "--templow":
        if len(sys.argv) < 3:
            print("Index required for --templow")
            sys.exit(1)
        print(onecall_weather(int(sys.argv[2]))["templow"])
    elif option == "--feel":
        print(onecall_weather()["feels_like"])
    elif option == "--stat":
        print(onecall_weather()["status"])
    elif option == "--humid":
        print(onecall_weather()["humidity"])
    elif option == "--wind":
        print(onecall_weather()["wind_speed"])
    elif option == "--clouds":
        print(onecall_weather()["clouds"])
    elif option == "--aqi":
        print(set_aqi()[0])
    elif option == "--aqi_color":
        print(set_aqi()[2])
    elif option == "--aqi_icon":
        print(set_aqi()[1])
    elif option == "--srise":
        if len(sys.argv) < 3:
            print("Index required for --srise")
            sys.exit(1)
        print(onecall_weather(day_index=int(sys.argv[2]))["sunrise"])
    elif option == "--sset":
        if len(sys.argv) < 3:
            print("Index required for --sset")
            sys.exit(1)
        print(onecall_weather(day_index=int(sys.argv[2]))["sunset"])
    else:
        print(
            "Usage: script.py {--getdata|--icon|--temp|--temphigh index|--templow index|--feel|--stat|--humid|--wind|--aqi|--aqi_color|--aqi_icon|--srise|--sset}"
        )
        sys.exit(1)


if __name__ == "__main__":
    main()
