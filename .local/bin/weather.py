#!/bin/python

import os
import argparse
import requests
import tomllib
import json
from typing import Any, Dict, Tuple, Literal, Optional, Union, TypedDict, NamedTuple


# TypedDicts
class WeatherData(TypedDict):
    temp: Union[int, float, None]
    feels_like: Union[int, float, None]
    icon: Optional[str]


class WaybarOutput(TypedDict):
    text: str
    tooltip: str
    class_: str  # use 'class_' since 'class' is reserved in Python


# NamedTuples
class IconResult(NamedTuple):
    icon: str
    color: str


# Define paths
HOME = os.path.expanduser("~")
CACHE_DIR = os.path.join(HOME, ".cache", "weather")
ONECALL_FILE = os.path.join(CACHE_DIR, "onecall.json")
AQI_FILE = os.path.join(CACHE_DIR, "aqidata.json")
CONFIG_FILE = os.path.join(HOME, ".local/share/location.toml")

with open(CONFIG_FILE, "rb") as f:
    config: Dict[str, Any] = tomllib.load(f)

API_KEY: str = config["API_KEY"]
LAT: float = config["LAT"]
LON: float = config["LON"]

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


def get_weather_data(units: Literal["imperial", "metric"]) -> None:
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
        "exclude": "minutely,hourly",
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


def get_jq_value(data: Any, query: str) -> Optional[Union[str, int, float, dict, list]]:
    keys = query.strip(".").split(".")
    for key in keys:
        if isinstance(data, list):
            idx = int(key)
            data = data[idx] if idx < len(data) else None
        elif isinstance(data, dict):
            data = data.get(key)
            if data is None:
                return None
    return data


def onecall_weather() -> WeatherData:
    data = load_json(ONECALL_FILE)
    return {
        "temp": get_jq_value(data, ".current.temp"),
        "feels_like": get_jq_value(data, ".current.feels_like"),
        "icon": get_jq_value(data, ".current.weather.0.icon"),
    }


def set_icon(code: str) -> IconResult:
    icon_map: Dict[str, IconResult] = {
        "01d": IconResult("󰖙", "#ffb86c"),
        "01n": IconResult("󰖔", "#bd93f9"),
        "02d": IconResult("󰖕", "#f1fa8c"),
        "02n": IconResult("󰼱", "#6272a4"),
        "03d": IconResult("󰖐", "#bd93f9"),
        "03n": IconResult("󰖐", "#bd93f9"),
        "04d": IconResult("󰖐", "#bd93f9"),
        "04n": IconResult("󰖐", "#bd93f9"),
        "09d": IconResult("󰖖", "#8be9fd"),
        "09n": IconResult("󰖖", "#8be9fd"),
        "10d": IconResult("󰼳", "#8be9fd"),
        "10n": IconResult("󰼳", "#8be9fd"),
        "11d": IconResult("󰼲", "#ffb86c"),
        "11n": IconResult("󰖓", "#ffb86c"),
        "13d": IconResult("󰼴", "#8be9fd"),
        "13n": IconResult("󰼶", "#8be9fd"),
        "50d": IconResult("󰼰", "#6272a4"),
        "50n": IconResult("󰖑", "#6272a4"),
    }
    return icon_map.get(code, IconResult("󰼯", "#ff5555"))


def waybar(units: Literal["imperial", "metric"]) -> None:
    weather = onecall_weather()
    icon_result: IconResult = set_icon(weather["icon"])
    temp = round(weather["temp"])
    feel = weather["feels_like"]
    unit_icon = "" if units == "imperial" else ""

    text: str = (
        f"<span size='18000'><span foreground='{icon_result.color}'>{icon_result.icon}</span></span> "
        f"{temp}{unit_icon}"
    )

    css_class: str = "hot" if temp >= 90 else "cold" if temp <= 32 else ""

    result: WaybarOutput = {
        "text": text,
        "class_": css_class,
    }

    print(json.dumps(result).replace("class_", "class"))


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
