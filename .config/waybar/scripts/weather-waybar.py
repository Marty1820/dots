#!/usr/bin/env python3
"""Waybar Open-Meteo weather module"""

import json
from pathlib import Path

CACHE = Path.home() / ".cache" / "weather" / "open-meteo.json"

# WMO weather interpretation codes -> icon
WMO_ICONS = {
    0: "󰖙",
    1: "󰖕",
    2: "󰖕",
    3: "󰖐",
    45: "󰖑",
    48: "󰖑",
    51: "󰼳",
    53: "󰙾",
    55: "󰖗",
    56: "󰼵",
    57: "󰙿",
    61: "󰼳",
    63: "󰖗",
    65: "󰙾",
    66: "󰙿",
    67: "󰙿",
    71: "󰼴",
    73: "󰖘",
    75: "󰼶",
    77: "󰖒",
    80: "󰼳",
    81: "󰖗",
    82: "󰙾",
    85: "󰼴",
    86: "󰼶",
    95: "󰖓",
    96: "󰙾",
    99: "󰙾",
}

WMO_CLASSES = {
    0: "clear",
    1: "partly",
    2: "partly",
    3: "cloudy",
    45: "fog",
    48: "fog",
    51: "rain",
    53: "rain",
    55: "rain",
    56: "rain",
    57: "rain",
    61: "rain",
    63: "rain",
    65: "rain",
    66: "rain",
    67: "rain",
    71: "snow",
    73: "snow",
    75: "snow",
    77: "snow",
    80: "rain",
    81: "rain",
    82: "rain",
    85: "snow",
    86: "snow",
    95: "storm",
    96: "storm",
    99: "storm",
}


def temp_class(temp: float) -> str:
    if temp <= 32:
        return "cold"
    if temp <= 75:
        return "mild"
    if temp <= 85:
        return "warm"
    return "hot"


def main() -> None:
    if not CACHE.exists():
        print(
            json.dumps({"text": "", "class": "unknown", "tooltip": "No weather data"})
        )
        return

    current = json.loads(CACHE.read_text()).get("current", {})
    temp = current.get("temperature_2m")
    if temp is None:
        print(
            json.dumps(
                {"text": "", "class": "unknown", "tooltip": "Weather unavailable"}
            )
        )
        return

    icon = WMO_ICONS.get(current.get("weather_code"), "󰼷")
    feels = current.get("apparent_temperature")
    humidity = current.get("relative_humidity_2m")
    wind = current.get("wind_speed_10m")
    cloud = current.get("cloud_cover")

    tooltip_lines = [
        f"Feels like: {feels:.0f}",
        f"Humidity: {humidity}",
        f"Wind: {wind} mph",
        f"Cloud cover: {cloud}",
    ]

    print(
        json.dumps(
            {
                "text": f"{icon} {temp:.0f}",
                "tooltip": "\n".join(tooltip_lines),
                # "class": f"{temp_class(temp)} {WMO_CLASSES.get(current.get('weather_code'), 'unknown')}",
                "class": temp_class(temp),
            }
        )
    )


if __name__ == "__main__":
    main()
