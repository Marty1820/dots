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
CONFIG_FILE = HOME / ".config" / "local_env.json"


def load_config() -> dict:
    """Loads configuration from a JSON file and validates structure."""
    try:
        config = json.loads(CONFIG_FILE.read_text(encoding="utf-8"))
        aqicn = config.get("aqicn", {})

        if not aqicn.get("token") or not aqicn.get("city"):
            logger.error("Missing 'aqicn.token' or 'aqicn.city' in config")

        cache_dir = config.get("cache_dir", str(HOME / ".cache" / "weather"))

        return {
            "aqi_url": aqicn["url"],
            "token": aqicn["token"],
            "city": aqicn["city"],
            "cache_directory": cache_dir,
        }
    except FileNotFoundError:
        raise RuntimeError(f"Config file not found: {CONFIG_FILE}")
    except json.JSONDecodeError as e:
        raise RuntimeError(f"Invalid JSON in config: {e}")


def fetch_aqi(url: str, token: str, city: str, cache_directory: str) -> None:
    """Fetch AQI data and save to cache."""
    cache_dir = Path(cache_directory)
    aqi_file = cache_dir / "aqidata.json"

    cache_dir.mkdir(parents=True, exist_ok=True)

    url = url.format(city=city)
    try:
        response = requests.get(url, params={"token": token}, timeout=10)
        response.raise_for_status()

        data = response.json()

        # Validate API response
        api_status = data.get("status")
        if api_status != "ok":
            error_msg = data.get("data", "unknown error")
            raise RuntimeError(f"WAQI API returned '{api_status}': {error_msg}")

        aqi_file.write_text(json.dumps(data, separators=(",", ":"), indent=2))
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
        fetch_aqi(
            config["aqi_url"],
            config["token"],
            config["city"],
            config["cache_directory"],
        )
        sys.exit(0)
    except RuntimeError as e:
        logger.error(str(e))
        sys.exit(1)
