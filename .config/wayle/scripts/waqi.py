#!/usr/bin/env python3

import json
import logging
import sys
from pathlib import Path
from typing import Optional, Dict, List

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
colors: List[str] = ["#50fa7b", "#F1fa8c", "#ffb86c", "#ff5555", "#bd93f9", "#ff79c6"]
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


def get_aqi_color(value, thresholds):
    if value is None:
        return "#f8f8f2"
    for i, threshold in enumerate(thresholds):
        if value <= threshold:
            return colors[i]
    return colors[-1]


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
        # color = get_aqi_color(val, POLLUTANT_THRESHOLDS[key])
        # lines.append(f'{label:<8}: <span color="{color}">{format_val(val)}</span>')
        lines.append(f"{label:<8}: {format_val(val)}")
    return "\n".join(lines)


def get_aqi_label(aqi_value):
    if aqi_value is None:
        return "Unknown"
    if aqi_value <= 50:
        return "Good"
    elif aqi_value <= 100:
        return "Moderate"
    elif aqi_value <= 150:
        return "Sensitive"
    elif aqi_value <= 200:
        return "Unhealthy"
    elif aqi_value <= 300:
        return "Very Unhealthy"
    else:
        return "Hazardous"


if __name__ == "__main__":
    aqi_data = safe_load(AQI_CACHE)

    aqi_value = None
    if aqi_data and "data" in aqi_data and "aqi" in aqi_data["data"]:
        try:
            aqi_value = int(aqi_data["data"]["aqi"])
        except ValueError:
            pass

    text = str(aqi_value) if aqi_value is not None else "UNK"
    label = get_aqi_label(aqi_value)
    css = label.lower().replace(" ", "_")
    tooltip = f"Overall : {label}\n{set_tooltip_info(aqi_data)}"

    output = {
        # "text": f'<span color="#f8f8f2">{text}</span>',
        "text": text,
        "tooltip": tooltip,
        "alt": label,
        "class": f"aqi-{css}",
    }

    print(json.dumps(output))
