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
        config = json.loads(CONFIG_FILE.read_text(encoding="utf-8"))
        aqicn = config.get("aqicn", {})

        if not aqicn.get("token") or not aqicn.get("city"):
            logger.error("Missing 'aqicn.token' or 'aqicn.city' in config")

        return {"token": aqicn["token"], "city": aqicn["city"]}
    except FileNotFoundError:
        raise RuntimeError(f"Config file not found: {CONFIG_FILE}")
    except json.JSONDecodeError as e:
        raise RuntimeError(f"Invalid JSON in config: {e}")


def fetch_aqi(token: str, city: str) -> None:
    """Fetch AQI data and save to cache."""
    CACHE_DIR.mkdir(parents=True, exist_ok=True)

    url = AQI_BASE.format(city=city)
    try:
        response = requests.get(url, params={"token": token}, timeout=TIMEOUT)
        response.raise_for_status()

        data = response.json()

        # Validate API response
        api_status = data.get("status")
        if api_status != "ok":
            error_msg = data.get("data", "unknown error")
            raise RuntimeError(f"WAQI API returned '{api_status}': {error_msg}")

        AQI_FILE.write_text(json.dumps(data, separators=(",", ":"), indent=2))
        logger.info("AQI data saved")

    except requests.HTTPError as e:
        raise RuntimeError(
            f"HTTP error fetching AQI data ({e.response.status_code}): {e}"
        )
    except requests.RequestException as e:
        raise RuntimeError(f"Failed to fetch AQI data: {e}")
    except OSError as e:
        raise RuntimeError(f"Failed to write cache file: {e}")


if __name__ == "__main__":
    try:
        config = load_config()
        fetch_aqi(config["token"], config["city"])
        sys.exit(0)
    except RuntimeError as e:
        logger.error(str(e))
        sys.exit(1)
