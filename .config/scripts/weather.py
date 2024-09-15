#!/usr/bin/env python3

import os
import requests
import json
import sys
from datetime import datetime

# Define paths
home = os.path.expanduser("~")
cache_dir = os.path.join(home, ".cache", "weather")
weather_file = os.path.join(cache_dir, "weatherdata.json")
weather_forecast = os.path.join(cache_dir, "weatherforecast.json")
aqi_file = os.path.join(cache_dir, "aqidata.json")
api_file_path = os.path.join(home, ".config", "scripts", "openweatherdata")

# Read API credentials and parameters
with open(api_file_path, "r") as file:
    api_key, lat, lon = [line.strip() for line in file]
unit = "imperial"  # Available options: 'metric' or 'imperial'

# Ensure cache directory exists
os.makedirs(cache_dir, exist_ok=True)


def fetch_data(url):
    response = requests.get(url)
    response.raise_for_status()
    return response.json()


def get_weather_data():
    base_url = "http://api.openweathermap.org/data/2.5/"
    params = f"appid={api_key}&lat={lat}&lon={lon}&units={unit}"
    urls = {
        "weather": base_url + "weather?" + params,
        "forecast": base_url + "forecast/daily?" + params + "&cnt=4",
        "air_pollution": base_url + "air_pollution?" + params,
    }
    data = {key: fetch_data(url) for key, url in urls.items()}

    with open(weather_file, "w") as f:
        json.dump(data["weather"], f, indent=4)
    with open(weather_forecast, "w") as f:
        json.dump(data["forecast"], f, indent=4)
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
            data = data[key]
        elif isinstance(data, dict):
            key = int(key) if key.isdigit() else key
            data = data.get(key, {})
        else:
            return None
    return data


def current_weather():
    data = load_json(weather_file)
    return {
        "temp": get_jq_value(data, ".main.temp"),
        "feels_like": get_jq_value(data, ".main.feels_like"),
        "status": get_jq_value(data, ".weather.0.main"),
        "city": get_jq_value(data, ".name"),
        "humidity": get_jq_value(data, ".main.humidity"),
        "wind_speed": get_jq_value(data, ".wind.speed"),
        "clouds": get_jq_value(data, ".clouds.all"),
        "icon": get_jq_value(data, ".weather.0.icon"),
    }


def forecast_weather(day_index):
    data = load_json(weather_forecast)
    day_data = lambda key: get_jq_value(data, f".list.{day_index}.{key}")

    return (
        day_data("temp.max"),
        day_data("temp.min"),
        (
            datetime.fromtimestamp(day_data("sunrise")).strftime("%I:%M %p")
            if day_data("sunrise")
            else None
        ),
        (
            datetime.fromtimestamp(day_data("sunset")).strftime("%I:%M %p")
            if day_data("sunset")
            else None
        ),
    )


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
    icon_code = current_weather()["icon"]
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
        print(current_weather()["temp"])
    elif option == "--temphigh":
        if len(sys.argv) < 3:
            print("Index required for --temphigh")
            sys.exit(1)
        print(forecast_weather(int(sys.argv[2]))[0])
    elif option == "--templow":
        if len(sys.argv) < 3:
            print("Index required for --templow")
            sys.exit(1)
        print(forecast_weather(int(sys.argv[2]))[1])
    elif option == "--feel":
        print(current_weather()["feels_like"])
    elif option == "--stat":
        print(current_weather()["status"])
    elif option == "--city":
        print(current_weather()["city"])
    elif option == "--humid":
        print(current_weather()["humidity"])
    elif option == "--wind":
        print(current_weather()["wind_speed"])
    elif option == "--clouds":
        print(current_weather()["clouds"])
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
        print(forecast_weather(int(sys.argv[2]))[2])
    elif option == "--sset":
        if len(sys.argv) < 3:
            print("Index required for --sset")
            sys.exit(1)
        print(forecast_weather(int(sys.argv[2]))[3])
    else:
        print(
            "Usage: script.py {--getdata|--icon|--temp|--temphigh index|--templow index|--feel|--stat|--city|--humid|--wind|--aqi|--aqi_color|--aqi_icon|--srise|--sset}"
        )
        sys.exit(1)


if __name__ == "__main__":
    main()
