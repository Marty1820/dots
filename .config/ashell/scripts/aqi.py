#!/usr/bin/env python3

import json
from pathlib import Path

# --- Configuration ---
HOME = Path.home()
CONFIG_FILE = HOME / ".config" / "local_env.json"
ICON_MAP = {
    "good": "󰡳 ",
    "moderate": "󰡵 ",
    "sensitive": "󰊚 ",
    "unhealthy": "󰡴 ",
    "very_unhealthy": "󰂧 ",
    "hazardous": "󰵄 ",
}


def load_config():
    conf = json.loads(CONFIG_FILE.read_text(encoding="utf-8"))
    return Path(conf["cache_dir"]) / conf["aqi_file"]


def get_aqi(path):
    try:
        with open(path) as f:
            return int(json.load(f).get("data", {}).get("aqi"))
    except Exception:
        return None


def get_category(aqi):
    thresholds = [
        (50, "good"),
        (100, "moderate"),
        (150, "sensitive"),
        (200, "unhealthy"),
        (300, "very_unhealthy"),
    ]
    for limit, label in thresholds:
        if aqi <= limit:
            return label
    return "hazardous" if aqi else "unknown"


def main() -> None:
    cache_path = load_config()
    aqi = get_aqi(cache_path)
    cat = get_category(aqi)
    icon = ICON_MAP.get(cat, "?")
    val = str(aqi) if aqi is not None else "UNK"
    print(json.dumps({"text": f"{icon} {val}", "alt": cat}))


if __name__ == "__main__":
    main()
