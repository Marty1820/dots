#!/usr/bin/env python3

import json
import logging
import sys
from pathlib import Path
from typing import Optional, Tuple, Dict, Any

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
        temp = round(w.get("temp", 0))
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
    if not aqi_data or "list" not in aqi_data:
        return ERROR_AQI_ICON, ERROR_COLOR

    try:
        aqi = aqi_data["list"][0]["main"]["aqi"]
        if not isinstance(aqi, int) or aqi < 1 or aqi > 5:
            logger.warning(f"Invalid AQI value: {aqi}")
            return ERROR_AQI_ICON, ERROR_COLOR
        return AQI_MAP.get(aqi, (ERROR_AQI_ICON, ERROR_COLOR))
    except (KeyError, IndexError, TypeError, ValueError) as e:
        logger.error(f"Error parsing AQI data: {e}")
        return ERROR_AQI_ICON, ERROR_COLOR


if __name__ == "__main__":
    weather_data = safe_load(ONECALL)
    aqi_data = safe_load(AQI)

    icon, color = get_weather_display(weather_data)
    aqi_icon, aqi_color = get_aqi_display(aqi_data)

    # Calculate temperature class
    temp = 0
    if weather_data and "current" in weather_data:
        try:
            temp = round(weather_data["current"].get("temp", 0))
        except (KeyError, TypeError):
            pass

    css_class = "hot" if temp > 90 else "cold" if temp < 32 else ""

    output = {
        "text": (
            f"<span foreground='{color}'>{icon}</span> "
            f"{temp} "
            f"<span foreground='{aqi_color}'>{aqi_icon}</span>"
        ),
        "class": css_class,
    }

    print(json.dumps(output))
