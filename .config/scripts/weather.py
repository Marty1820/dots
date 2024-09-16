#!/usr/bin/env python3

import os
import requests
import json
import sys
from datetime import datetime

# Define paths
home = os.path.expanduser("~")
api_file_path = os.path.join(home, ".config", "scripts", "openweatherdata")
cache_dir = os.path.join(home, ".cache", "weather")
onecall_file = os.path.join(cache_dir, "onecall.json")
weather_file = os.path.join(cache_dir, "weatherdata.json")
aqi_file = os.path.join(cache_dir, "aqidata.json")

# Read API credentials and parameters
with open(api_file_path, "r") as file:
    api_key, lat, lon = [line.strip() for line in file]

unit = "imperial"  # Available options: 'metric' or 'imperial'

# Ensure cache directory exists
os.makedirs(cache_dir, exist_ok=True)


def fetch_data(url):
    try:
        response = requests.get(url)
        response.raise_for_status()
        return response.json()
    except requests.RequestException as e:
        print(f"Error fetching data: {e}")
        sys.exit(1)


def get_weather_data():
    base_url = "http://api.openweathermap.org/data/"
    params = f"appid={api_key}&lat={lat}&lon={lon}&units={unit}"
    excludes = f"&exlude=minutely,hourly"
    urls = {
        "onecall": base_url + "3.0/onecall?" + params + excludes,
        "weather": base_url + "2.5/weather?" + params,
        "air_pollution": base_url + "2.5/air_pollution?" + params,
    }

    data = {key: fetch_data(url) for key, url in urls.items()}

    with open(onecall_file, "w") as f:
        json.dump(data["onecall"], f, indent=4)
    with open(weather_file, "w") as f:
        json.dump(data["weather"], f, indent=4)
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

    return {
        "temp": get_jq_value(data, ".current.temp"),
        "feels_like": get_jq_value(data, ".current.feels_like"),
        "status": get_jq_value(data, ".current.weather.0.main"),
        # "city": get_jq_value(data, f".current."),
        "humidity": get_jq_value(data, ".current.humidity"),
        "wind_speed": get_jq_value(data, ".current.wind_speed"),
        "clouds": get_jq_value(data, ".current.clouds"),
        "icon": get_jq_value(data, ".current.weather.0.icon"),
        "temphigh": get_jq_value(data, temp_high_query),
        "templow": get_jq_value(data, temp_low_query),
        "sunrise": (
            datetime.fromtimestamp(get_jq_value(data, sunrise_query)).strftime(
                "%I:%M %p"
            )
            if get_jq_value(data, sunrise_query)
            else None
        ),
        "sunset": (
            datetime.fromtimestamp(get_jq_value(data, sunset_query)).strftime(
                "%I:%M %p"
            )
            if get_jq_value(data, sunset_query)
            else None
        ),
    }


def current_weather():
    data = load_json(weather_file)
    return {
        "city": get_jq_value(data, ".name"),
    }


def set_aqi():
    data = load_json(aqi_file)
    aqi_data = get_jq_value(data, ".list.0.main.aqi")
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
            "Usage: script.py {--getdata|--icon|--temp|--temphigh index|--templow index|--feel|--stat|--city|--humid|--wind|--aqi|--aqi_color|--aqi_icon|--srise|--sset}"
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
    elif option == "--city":
        print(current_weather()["city"])
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
            "Usage: script.py {--getdata|--icon|--temp|--temphigh index|--templow index|--feel|--stat|--city|--humid|--wind|--aqi|--aqi_color|--aqi_icon|--srise|--sset}"
        )
        sys.exit(1)


if __name__ == "__main__":
    main()
