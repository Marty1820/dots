#!/usr/bin/env python3

import json
import logging
import sys
from bisect import bisect_right
from pathlib import Path
from typing import Optional, Dict, List, Any

# --- Configuration ---
HOME = Path.home()
CONFIG_FILE = HOME / ".config" / "local_env.json"

POLLUTANT_THRESHOLDS: Dict[str, list] = {
    "co": [4.5, 9.5, 12.5, 15.5, 30.5],
    "no2": [54, 101, 361, 650, 1250],
    "o3": [55, 71, 86, 106, 404],
    "pm10": [55, 155, 255, 355, 425],
    "pm25": [9.1, 35.5, 55.5, 125.5, 225.5],
    "so2": [36, 76, 186, 305, 605],
}
COLORS: List[str] = ["#50fa7b", "#F1fa8c", "#ffb86c", "#ff5555", "#bd93f9", "#ff79c6"]
POLLUTANTS: List[tuple] = [
    ("co", "CO"),
    ("no2", "NO²"),
    ("o3", "O³"),
    ("pm10", "PM¹⁰"),
    ("pm25", "PM²⁵"),
    ("so2", "SO²"),
]


def setup_logging() -> None:
    """Config stderr-based logging."""
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s [%(levelname)s] %(message)s",
        stream=sys.stderr,
    )


def load_json_file() -> Optional[Dict[str, Any]]:
    """Load JSON from file."""
    config = json.loads(CONFIG_FILE.read_text(encoding="utf-8"))
    cache_dir = config.get("cache_dir")
    cache_file = config.get("aqi_file")
    path = Path(cache_dir) / Path(cache_file)

    try:
        with open(path, encoding="utf-8") as f:
            return json.load(f)
    except json.JSONDecodeError as e:
        logging.error(f"Invalid JSON at {path}: {e}")
    except UnicodeDecodeError as e:
        logging.error(f"Encoding error at {path}: {e}")
    except PermissionError as e:
        logging.error(f"Permission denied at {path}: {e}")
    except OSError as e:
        logging.error(f"IO error at {path}: {e}")

    return None


def extract_pollutant_value(data: Optional[Dict], key: str) -> Optional[float]:
    """Safely extract pollutant value from nested AQI API response."""
    if not isinstance(data, dict):
        return None
    try:
        val = data.get("data", {}).get("iaqi", {}).get(key.lower(), {}).get("v")
        return float(val) if val is not None else None
    except (TypeError, ValueError):
        return None


def get_aqi_category(value: Optional[int]) -> str:
    """Map numeric AQI to human-readable category."""
    if value is None:
        return "unknown"
    categories = [
        (50, "good"),
        (100, "moderate"),
        (150, "sensitive"),
        (200, "unhealthy"),
        (300, "very_unhealthy"),
    ]
    for threshold, label in categories:
        if value <= threshold:
            return label
    return "hazardous"


def compute_color_index(value: float, thresholds: List[float]) -> int:
    """Binary search threshold index for color lookup."""
    idx = bisect_right(thresholds, value)
    return min(idx, len(COLORS) - 1)


def build_tooltip(data: Optional[Dict]) -> str:
    """Construct multi-line tooltip string with all pollutants."""
    lines = []
    overall_label = "Unknown"

    if data:
        aqi_val = data.get("data", {}).get("aqi")
        try:
            overall_label = get_aqi_category(int(aqi_val))
        except (ValueError, TypeError):
            pass

        for key, label in POLLUTANTS:
            val = extract_pollutant_value(data, key)
            # Colors reserved for future feature activation
            # thresh = POLLUTANT_THRESHOLDS[key]
            # color = COLORS[compute_color_index(val, thresh)] if val else "#f8f8f2"
            # lines.append(f'{label:<8}: <span color="{color}">{val:.1f}</span>' if val else f'{label:<8}: --')
            lines.append(f"{label:<8}: {'--' if val is None else f'{val:.1f}'}")

    return f"Overall : {overall_label.title()}\n" + "\n".join(lines)


def generate_output(data: Optional[Dict]) -> Dict[str, str]:
    """Build final JSON payload for consumer application."""
    aqi_value = None
    if data:
        try:
            aqi_value = int(data.get("data", {}).get("aqi"))
        except (ValueError, TypeError):
            pass

    text = str(aqi_value) if aqi_value is not None else "UNK"
    category = get_aqi_category(aqi_value)
    css_class = f"aqi-{category}"
    tooltip = build_tooltip(data)

    return {
        "text": text,
        "tooltip": tooltip,
        "alt": category.replace("_", " ").title(),
        "class": css_class,
        # "text_colored": f'<span color="#f8f8f2">{text}</span>',  # Reserved
    }


if __name__ == "__main__":
    setup_logging()

    data = load_json_file()
    result = generate_output(data)

    print(json.dumps(result))
