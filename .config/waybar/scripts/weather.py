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

ERROR_ICON = "󰼯"
ERROR_AQI_ICON = "󰻝"
ERROR_COLOR = "#ff5555"


def safe_load(path):
    try:
        with open(path) as f:
            return json.load(f)
    except Exception:
        return None


if __name__ == "__main__":
    weather_data = safe_load(ONECALL)
    aqi_data = safe_load(AQI)

    if weather_data and "current" in weather_data:
        w = weather_data["current"]
        temp = round(w.get("temp", 0))
        icon_code = w.get("weather", [{}])[0].get("icon")
        icon, color = ICON_MAP.get(icon_code, (ERROR_ICON, ERROR_COLOR))
    else:
        temp = 0
        icon, color = ERROR_ICON, ERROR_COLOR

    if aqi_data:
        try:
            aqi = aqi_data["list"][0]["main"]["aqi"]
            aqi_icon, aqi_color = AQI_MAP.get(aqi, (ERROR_AQI_ICON, ERROR_COLOR))
        except Exception:
            aqi_icon, aqi_color = ERROR_AQI_ICON, ERROR_COLOR
    else:
        aqi_icon, aqi_color = ERROR_AQI_ICON, ERROR_COLOR

    css = "hot" if temp > 90 else "cold" if temp < 32 else ""

    print(
        json.dumps(
            {
                "text": (
                    f"<span foreground='{color}'>{icon}</span> "
                    f"{temp} "
                    f"<span foreground='{aqi_color}'>{aqi_icon}</span>"
                ),
                "class": css,
            }
        )
    )
