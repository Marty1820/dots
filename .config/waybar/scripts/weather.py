#!/usr/bin/env python3

import json
import logging
import sys
from pathlib import Path
from typing import Optional, Tuple, Dict, Any, List

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    stream=sys.stderr,
)
logger = logging.getLogger(__name__)

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

AQI_MAP = [
    (19, ("󰡳", "#50fa7b")),
    (49, ("󰡵", "#f1fa8c")),
    (99, ("󰊚", "#ffb86c")),
    (149, ("󰡴", "#ff5555")),
    (249, ("", "#ff79c6")),
    (500, ("󰐼", "#bd93f9")),
]

AQI_COLORS = {
    1: "#50fa7b",  # Good
    2: "#f1fa8c",  # Moderate
    3: "#ffb86c",  # Unhealthy for Sensitive Groups
    4: "#ff5555",  # Unhealthy
    5: "#ff79c6",  # Very Unhealthy
    6: "#bd93f9",  # Hazardous
    7: "#f8f8f2",  # Unknown
}

ERROR_ICON = "󰼯"
ERROR_AQI_ICON = "󰻝"
ERROR_COLOR = "#ff5555"

# Pollutant thresholds (upper bounds, ascending). Index->category (1-based)
POLLUTANT_THRESHOLDS: Dict[str, List[float]] = {
    "co": [4.4, 9.4, 12.4, 15.4, 30.4, 40.4, 50.4],
    "no2": [53, 100, 360, 649, 1249, 1649, 2049],
    "o3": [54, 70, 85, 105, 200],
    "pm10": [54, 154, 254, 354, 424, 504, 604],
    "pm25": [12, 35.4, 55.4, 150.4, 250.4, 350.4],
    "so2": [35, 75, 185, 304, 604, 804, 1004],
}


def safe_load(path: Path) -> Optional[Dict[str, Any]]:
    """Load JSON with detailed error logging."""
    try:
        if not path.exists():
            logger.warning(f"Cache file not found: {path}")
            return None
        with open(path) as f:
            data = json.load(f)
            if not isinstance(data, dict):
                logger.error(f"Invalid JSON structure in {path}")
                return None
            return data
    except json.JSONDecodeError as e:
        logger.error(f"JSON decode error in {path}: {e}")
        return None
    except PermissionError as e:
        logger.error(f"Permission denied reading {path}: {e}")
        return None
    except Exception as e:
        logger.error(f"Unexpected error loading {path}: {e}")
        return None


def get_weather_display(weather_data: Optional[Dict]) -> Tuple[str, str]:
    """Extract weather icon and color with fallbacks."""
    if not weather_data or "current" not in weather_data:
        return ERROR_ICON, ERROR_COLOR

    try:
        w = weather_data["current"]
        icon_code = w.get("weather", [{}])[0].get("icon")

        if not icon_code:
            logger.warning("No weather icon code found")
            return ERROR_ICON, ERROR_COLOR

        icon, color = ICON_MAP.get(icon_code, (ERROR_ICON, ERROR_COLOR))
        return icon, color
    except (KeyError, IndexError, TypeError) as e:
        logger.error(f"Error parsing weather data: {e}")
        return ERROR_ICON, ERROR_COLOR


def get_aqi_display(aqi_data: Optional[Dict]) -> Tuple[str, str]:
    """Extract AQI icon and color with fallbacks."""
    if not aqi_data:
        return ERROR_AQI_ICON, ERROR_COLOR

    try:
        aqi = aqi_data["data"]["aqi"]
        if not isinstance(aqi, (int, float)):
            logger.warning(f"Invalid AQI value: {aqi}")
            return ERROR_AQI_ICON, ERROR_COLOR
        aqi_val = int(aqi)
        for max_val, (icon, color) in AQI_MAP:
            if aqi_val <= max_val:
                return icon, color
        # If larger than all buckets
        return AQI_MAP[-1][1]
    except (KeyError, IndexError, TypeError, ValueError) as e:
        logger.error(f"Error parsing AQI data: {e}")
        return ERROR_AQI_ICON, ERROR_COLOR


def set_weather_class(weather_data: Optional[Dict]) -> Tuple[int, str]:
    """Calculate Temperature and CSS class"""
    temp = 0
    if weather_data and "current" in weather_data:
        try:
            temp = round(weather_data["current"].get("temp", 0))
        except (KeyError, TypeError):
            pass

    css_class = "hot" if temp > 90 else "cold" if temp < 32 else ""

    return temp, css_class


def pull_aqi_value(aqi_data: Optional[Dict], name: str) -> Optional[float]:
    """Safely extract IAQI pollutant value. Normalizes pollutant keys."""
    if not aqi_data:
        return None
    key = name.lower()
    candidates = [key]

    for k in candidates:
        try:
            v = aqi_data["data"]["iaqi"].get(k)
            if v and "v" in v:
                try:
                    return float(v["v"])
                except (TypeError, ValueError):
                    logger.debug(f"Non-numeric IAQI value for {k}: {v['v']}")
                    return None
        except (KeyError, TypeError):
            continue

    logger.debug(f"IAQI pollutant '{name}' not found")
    return None


def set_aqi_category(value: Optional[float], pollutant: str) -> int:
    """Return category 1..N for pollutant ranges"""
    if value is None:
        return 7
    p = pollutant.lower()

    thresholds = POLLUTANT_THRESHOLDS.get(p)
    if not thresholds:
        logger.debug(f"No thresholds defined for pollutant '{pollutant}'")
        return 7

    for idx, upper in enumerate(thresholds, start=1):
        if value <= upper:
            return idx
    # If above threshold, return highest category
    return min(len(thresholds) + 1, 7)


def category_color(value: Optional[float], pollutant: str) -> str:
    cat = set_aqi_category(value, pollutant)
    return AQI_COLORS.get(cat, AQI_COLORS[7])


def set_tooltip_info(aqi_data: Optional[Dict]) -> str:
    """Format AQI information to show on module hover"""
    co = pull_aqi_value(aqi_data, "co")
    no2 = pull_aqi_value(aqi_data, "no2")
    o3 = pull_aqi_value(aqi_data, "o3")
    pm10 = pull_aqi_value(aqi_data, "pm10")
    pm25 = pull_aqi_value(aqi_data, "pm25")
    so2 = pull_aqi_value(aqi_data, "so2")

    tooltip = (
        f"<span foreground='{category_color(co, 'co')}'>CO    : {co}</span>\n"
        f"<span foreground='{category_color(no2, 'no2')}'>NO²   : {no2}</span>\n"
        f"<span foreground='{category_color(o3, 'o3')}'>O³    : {o3}</span>\n"
        f"<span foreground='{category_color(pm10, 'pm10')}'>PM10  : {pm10}</span>\n"
        f"<span foreground='{category_color(pm25, 'pm25')}'>PM2.5 : {pm25}</span>\n"
        f"<span foreground='{category_color(so2, 'so2')}'>SO²   : {so2}</span>"
    )

    return tooltip


if __name__ == "__main__":
    weather_data = safe_load(ONECALL)
    aqi_data = safe_load(AQI)

    temp, css_class = set_weather_class(weather_data)
    icon, color = get_weather_display(weather_data)
    aqi_icon, aqi_color = get_aqi_display(aqi_data)
    tooltip = set_tooltip_info(aqi_data)

    output = {
        "text": (
            f"<span foreground='{color}'>{icon}</span> "
            f"{temp} "
            f"<span foreground='{aqi_color}'>{aqi_icon}</span>"
        ),
        "tooltip": tooltip,
        "class": css_class,
    }

    print(json.dumps(output))
