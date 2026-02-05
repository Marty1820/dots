#!/usr/bin/env python3

from pathlib import Path
import json

CACHE = Path.home() / ".cache" / "weather"
ONECALL = CACHE / "onecall.json"
AQI = CACHE / "aqidata.json"

ICON_MAP = {
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

AQI_MAP = {
    1: ("󰡳", "#50fa7b"),
    2: ("󰡵", "#f1fa8c"),
    3: ("󰊚", "#ffb86c"),
    4: ("󰡴", "#ff5555"),
    5: ("", "#bd93f9"),
}


def load(path):
    with open(path) as f:
        return json.load(f)


def waybar():
    w = load(CACHE / "onecall.json")["current"]
    aqi = load(CACHE / "aqidata.json")["list"][0]["main"]["aqi"]

    temp = round(w["temp"])
    icon, color = ICON_MAP.get(w["weather"][0]["icon"], ("󰼯", "#ff5555"))
    aqi_icon, aqi_color = AQI_MAP.get(aqi, ("󰻝", "#ff5555"))

    unit = ""
    css = "hot" if temp > 90 else "cold" if temp < 32 else ""

    text = (
        f"<span size='18000'><span foreground='{color}'>{icon}</span></span> "
        f"{temp}{unit}"
        f"<span foreground='{aqi_color}'>{aqi_icon}</span>"
    )

    print(
        json.dumps(
            {
                "text": (
                    f"<span size='18000'><span foreground='{color}'>{icon}</span></span> "
                    f"{temp}{unit}"
                    f"<span foreground='{aqi_color}'>{aqi_icon}</span>"
                ),
                "class": css,
            }
        )
    )


if __name__ == "__main__":
    waybar()
