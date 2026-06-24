#!/usr/bin/env python3

import json
import logging
import sys
from pathlib import Path
from typing import Optional, Dict

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    stream=sys.stderr,
)
logger = logging.getLogger(__name__)

AQI_CACHE = Path.home() / ".cache" / "weather" / "aqidata.json"

POLLUTANT_THRESHOLDS: Dict[str, list] = {
    "co": [4.4, 9.4, 12.4, 15.4, 30.4, 1004],
    "no2": [53, 100, 360, 649, 1249, 2049],
    "o3": [54, 70, 85, 105, 200, 605],
    "pm10": [54, 154, 254, 354, 424, 504, 604],
    "pm25": [12, 35.4, 55.4, 150.4, 250.4, 500.4],
    "so2": [35, 75, 185, 304, 604, 1004],
}
MAX_AQI = 200


def safe_load(path: Path) -> Optional[Dict]:
    try:
        if not path.exists():
            logger.warning(f"Cache file not found: {path}")
            return None
        with open(path) as f:
            return json.load(f)
    except Exception as e:
        logger.error(f"Error loading {path}: {e}")
        return None


def pull_aqi_value(data, name):
    if not data:
        return None
    try:
        val = data["data"]["iaqi"][name.lower()]["v"]
        return float(val)
    except Exception:
        return None


def format_val(val):
    return f"{val:.1f}" if val is not None else "--"


def set_tooltip_info(data):
    pollutants = [
        ("co", "CO"),
        ("no2", "NO²"),
        ("o3", "O³"),
        ("pm10", "PM¹⁰"),
        ("pm25", "PM²⁵"),
        ("so2", "SO²"),
    ]
    lines = []
    for key, label in pollutants:
        val = pull_aqi_value(data, key)
        lines.append(f"{label:<5}: {format_val(val)}")
    return "\n".join(lines)


def get_aqi_label(aqi_value):
    if aqi_value is None:
        return "Unknown"
    if aqi_value <= 50:
        return "good"
    elif aqi_value <= 100:
        return "moderate"
    elif aqi_value <= 150:
        return "sensitive"
    elif aqi_value <= 200:
        return "unhealthy"
    elif aqi_value <= 300:
        return "veryunhealthy"
    else:
        return "hazardous"


if __name__ == "__main__":
    aqi_data = safe_load(AQI_CACHE)

    aqi_value = None
    if aqi_data and "data" in aqi_data and "aqi" in aqi_data["data"]:
        try:
            aqi_value = int(aqi_data["data"]["aqi"])
        except ValueError:
            pass

    label = get_aqi_label(aqi_value)

    output = {
        "text": str(aqi_value) if aqi_value is not None else "?",
        "alt": label,
        "class": label,
        "tooltip": set_tooltip_info(aqi_data),
    }

    print(json.dumps(output))
