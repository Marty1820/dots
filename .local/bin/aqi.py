#!/usr/bin/env python3

# pacman -S python-requests

import requests
import json
import logging
import sys
from pathlib import Path

# Systemd logging integration
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s = %(levelname)s = %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
    stream=sys.stderr,
)
logger = logging.getLogger(__name__)

# Define paths
HOME = Path.home()
CACHE_DIR = HOME / ".cache" / "weather"
AQI_FILE = CACHE_DIR / "aqidata.json"
CONFIG_FILE = HOME / ".config" / "local_env.json"

AQI_BASE = "https://api.waqi.info/feed/@{city}/"
TIMEOUT = 10


def load_config() -> dict:
    """Loads configuration from a JSON file and validates structure."""
    try:
        config = json.loads(CONFIG_FILE.read_text())
        aqicn = config.get("aqicn", {})

        if not aqicn.get("token") or not aqicn.get("city"):
            logger.error("Missing 'aqicn.token' or 'aqicn.city' in config")
            sys.exit(1)

        return {"token": aqicn["token"], "city": aqicn["city"]}
    except FileNotFoundError:
        logger.error(f"Config file not found: {CONFIG_FILE}")
        sys.exit(1)
    except json.JSONDecodeError as e:
        logger.error(f"Invalid JSON in config: {e}")
        sys.exit(1)


def fetch_aqi(token: str, city: str) -> None:
    """Fetch AQI data and save to cache."""
    CACHE_DIR.mkdir(parents=True, exist_ok=True)

    url = AQI_BASE.format(city=city)
    try:
        response = requests.get(url, params={"token": token}, timeout=TIMEOUT)
        response.raise_for_status()

        data = response.json()
        AQI_FILE.write_text(json.dumps(data, indent=2))
        logger.info("AQI data saved")
    except requests.RequestException as e:
        logger.error(f"Failed to fetch AQI data: {e}")
        sys.exit(1)
    except OSError as e:
        logger.error(f"Failed to write cache file: {e}")
        sys.exit(1)


if __name__ == "__main__":
    config = load_config()
    fetch_aqi(config["token"], config["city"])
