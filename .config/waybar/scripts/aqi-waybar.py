#!/usr/bin/env python3
"""Waybar module: AQI"""

import json
from pathlib import Path

# --- Configuration ---
CACHE = Path.home() / ".cache" / "weather" / "aqidata.json"

# Pollutant keys as WAQI returns them in iaqi -> (label, order in tooltip)
POLLUTANTS = [
    ("pm25", "PM2.5"),
    ("pm10", "PM10"),
    ("o3", "O₃"),
    ("no2", "NO₂"),
    ("so2", "SO₂"),
    ("co", "CO"),
]


def band(aqi: int) -> str:
    if aqi <= 50:
        return "good"
    if aqi <= 100:
        return "moderate"
    if aqi <= 150:
        return "sensitive"
    if aqi <= 200:
        return "unhealthy"
    if aqi <= 300:
        return "very-unhealthy"
    return "hazardous"


ICONS = {
    "good": "󰡳",
    "moderate": "󰡵",
    "sensitive": "󰊚",
    "unhealthy": "󰡴",
    "very-unhealthy": "",
    "hazardous": "",
}


def main() -> None:
    if not CACHE.exists():
        print(json.dumps({"text": "", "class": "unknown", "tooltip": "No AQI data"}))
        return

    data = json.loads(CACHE.read_text()).get("data", {})
    aqi = data.get("aqi")
    if aqi is None:
        print(
            json.dumps({"text": "", "class": "unknown", "tooltip": "AQI unavailable"})
        )
        return

    b = band(aqi)
    iaqi = data.get("iaqi", {})

    lines = []
    for key, label in POLLUTANTS:
        v = iaqi.get(key, {}).get("v")
        if v is None:
            continue
        lines.append(f"{label}: {v}")

    print(
        json.dumps(
            {
                "text": f"{ICONS[b]} {aqi}",
                "tooltip": f"AQI: {aqi}\n\n" + "\n".join(lines),
                "class": b,
            }
        )
    )


if __name__ == "__main__":
    main()
