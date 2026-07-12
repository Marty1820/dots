#!/usr/bin/env python3

import json
import time
from pathlib import Path

# --- Configuration ---
HOME = Path.home()
CONFIG_FILE = HOME / ".config" / "local_env.json"
POLL_INTERVAL = 10  # seconds between mtime checks


def load_config():
    conf = json.loads(CONFIG_FILE.read_text(encoding="utf-8"))
    return Path(conf["cache_dir"]) / conf["aqi_file"]


def get_aqi(path):
    try:
        with open(path) as f:
            return int(json.load(f).get("data", {}).get("aqi"))
    except (json.JSONDecodeError, ValueError, TypeError):
        return None


def get_category(aqi):
    if aqi is None:
        return "unknown"

    thresholds = [
        (50, "good"),
        (100, "moderate"),
        (150, "sensitive"),
        (200, "unhealthy"),
        (300, "very_unhealthy"),
        (float("inf"), "hazardous"),
    ]

    return next(label for limit, label in thresholds if aqi <= limit)


def emit(aqi):
    cat = get_category(aqi)
    val = str(aqi) if aqi is not None else "UNK"
    print(json.dumps({"text": val, "alt": cat}), flush=True)


if __name__ == "__main__":
    cache_path = load_config()
    last_mtime = None

    while True:
        try:
            mtime = cache_path.stat().st_mtime_ns
        except FileNotFoundError:
            mtime = None

        if mtime != last_mtime:
            last_mtime = mtime
            aqi = get_aqi(cache_path) if mtime is not None else None
            emit(aqi)

        time.sleep(POLL_INTERVAL)
