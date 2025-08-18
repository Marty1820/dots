#!/bin/python

import os
import argparse
import requests
import tomllib
import json
from typing import Any, Dict, Tuple


# Define paths
HOME = os.path.expanduser("~")
CACHE_DIR = os.path.join(HOME, ".cache", "weather")
ONECALL_FILE = os.path.join(CACHE_DIR, "onecall.json")
AQI_FILE = os.path.join(CACHE_DIR, "aqidata.json")
CONFIG_FILE = os.path.join(HOME, ".local/share/location.toml")

with open(CONFIG_FILE, "rb") as f:
    config: Dict[str, Any] = tomllib.load(f)

API_KEY = config["API_KEY"]
LAT = config["LAT"]
LON = config["LON"]

# Ensure cache directory exists
os.makedirs(CACHE_DIR, exist_ok=True)


def fetch_data(url: str, params: Dict[str, Any]) -> Dict[str, Any]:
    try:
        response = requests.get(url, params=params)
        response.raise_for_status()
        return response.json()
    except requests.RequestException as e:
        print(f"Error fetching data: {e}")
        raise SystemExit(1)


def get_weather_data(units: str) -> None:
    base_url: str = "http://api.openweathermap.org/data/"
    urls: Dict[str, str] = {
        "onecall": base_url + "3.0/onecall?",
        "air_pollution": base_url + "2.5/air_pollution?",
    }
    params: Dict[str, Any] = {
        "appid": API_KEY,
        "lat": LAT,
        "lon": LON,
        "units": units,
    }

    data: Dict[str, Any] = {key: fetch_data(url, params) for key, url in urls.items()}

    with open(ONECALL_FILE, "w") as f:
        json.dump(data["onecall"], f, indent=2)
    with open(AQI_FILE, "w") as f:
        json.dump(data["air_pollution"], f, indent=2)

    print("Data successfully fetched and saved.")


def load_json(file_path: str) -> Any:
    with open(file_path, "r") as f:
        return json.load(f)


def get_jq_value(data: Any, query: str) -> Any:
    keys = query.strip(".").split(".")
    for key in keys:
        if isinstance(data, list):
            key = int(key)
            data = data[key] if key < len(data) else None
        elif isinstance(data, dict):
            data = data.get(key)
            if data is None:
                return None
    return data


def onecall_weather() -> Dict[str, Any]:
    data = load_json(ONECALL_FILE)
    return {
        "temp": get_jq_value(data, ".current.temp"),
        "feels_like": get_jq_value(data, ".current.feels_like"),
        "icon": get_jq_value(data, ".current.weather.0.icon"),
    }


def set_aqi() -> Tuple[str, str]:
    aqi = get_jq_value(load_json(AQI_FILE), ".list.0.main.aqi") or -1
    aqi_map: Dict[int, Tuple[str, str]] = {
        1: ("󰡳", "#50fa7b"),
        2: ("󰡵", "#f1fa8c"),
        3: ("󰊚", "#ffb86c"),
        4: ("󰡴", "#ff5555"),
        5: ("", "#bd93f9"),
    }
    return aqi_map.get(aqi, ("󰻝", "#ff5555"))


def set_icon(code: str) -> Tuple[str, str]:
    icon_map: Dict[str, Tuple[str, str]] = {
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
    return icon_map.get(code, ("󰼯", "#ff5555"))


def waybar(units: str) -> None:
    weather = onecall_weather()
    icon, color = set_icon(weather["icon"])
    temp = round(weather["temp"])
    feel = weather["feels_like"]
    aqi_icon, aqi_color = set_aqi()
    unit_icon = "" if units == "imperial" else ""

    text: str = (
        f"<span size='18000'><span foreground='{color}'>{icon}</span></span> "
        f"{temp}{unit_icon}"
    )

    tooltip: str = (
        f"Real Feel: {feel:.1f}{unit_icon}\n"
        f"AQI: <span foreground='{aqi_color}'>{aqi_icon}</span>"
    )

    css_class: str = "hot" if temp > 90 else "cold" if temp < 32 else ""

    print(json.dumps({"text": text, "tooltip": tooltip, "class": css_class}))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Weather script.")
    parser.add_argument(
        "option", choices=["getdata", "waybar"], help="Option to select"
    )
    parser.add_argument(
        "--units",
        choices=["imperial", "metric"],
        default="imperial",
        help="Choose units (imperial = F, metric = C)",
    )
    args = parser.parse_args()

    if args.option == "getdata":
        get_weather_data(args.units)
    elif args.option == "waybar":
        waybar(args.units)
