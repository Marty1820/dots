#!/usr/bin/env python3

import argparse
import json
import logging
import requests
import sys
import subprocess
import signal
from pathlib import Path
from typing import Any, Dict, Literal

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
ONECALL_FILE = CACHE_DIR / "onecall.json"
AQI_FILE = CACHE_DIR / "aqidata.json"
CONFIG_FILE = HOME / ".config" / "local_env.json"

# Constants
ONECALL_URL = "https://api.openweathermap.org/data/3.0/onecall"
AQI_BASE = "https://api.waqi.info/feed/@{city}/"
TIMEOUT = 10


def load_config(config_file: Path) -> Dict[str, Any]:
    """Loads configuration from a JSON file."""
    try:
        with config_file.open("r") as f:
            cfg = json.load(f)
    except FileNotFoundError:
        logger.error(f"Error: Configuration file not found at {config_file}")
        sys.exit(1)
    except json.JSONDecodeError as e:
        logger.error(f"Error decoding JSON file: {e}")
        sys.exit(1)

    openweather = cfg.get("openweather")
    coords = cfg.get("coords")
    aqicn = cfg.get("aqicn")

    # Validate required keys
    if not isinstance(openweather, dict) or "api_key" not in openweather:
        logger.error("Missing 'openweather.api_key' in config")
        sys.exit(1)
    if not isinstance(coords, dict) or "lat" not in coords or "lon" not in coords:
        logger.error("Missing 'coords.lat|.lon' in config")
        sys.exit(1)
    if not isinstance(aqicn, dict) or "api_key" not in aqicn or "aqi_city" not in aqicn:
        logger.error("Missing 'aqicn.api_key|aqi_city' in config")
        sys.exit(1)

    logger.debug(f"Config loaded successfully from {config_file}")
    return {
        "API_KEY": str(openweather["api_key"]),
        "LAT": coords["lat"],
        "LON": coords["lon"],
        "AQI_KEY": str(aqicn["api_key"]),
        "AQI_LOC": str(aqicn["aqi_city"]),
    }


def fetch_data(
    session: requests.Session, url: str, params: Dict[str, Any] = None
) -> Dict[str, Any]:
    """Fetches data using a persistent session."""
    try:
        logger.debug("GET %s params=%s", url, params)
        response = session.get(url, params=params, timeout=TIMEOUT)
        response.raise_for_status()
        logger.debug(f"Successfully fetched data from {url}")
        return response.json()
    except requests.RequestException as e:
        logger.error(f"Error fetching data from {url}: {e}")
        sys.exit(1)


def reload_waybar() -> None:
    """Sends a signal to Waybar to force a module reload."""
    try:
        rt_signal = signal.SIGRTMIN + 10
        subprocess.run(["pkill", f"-{rt_signal}", "waybar"], check=False)
        logger.info(f"Waybar reloaded (Signal {rt_signal})")
    except Exception as e:
        logger.warning(f"Failed to send signal to waybar: {e}")


def get_aqi_data(token: str, city: str) -> None:
    """Fetch AQI and save to file."""
    CACHE_DIR.mkdir(parents=True, exist_ok=True)

    # url: str = f"https://api.waqi.info/feed/@{city}/"
    url = AQI_BASE.format(city=city)
    params = {"token": token}

    with requests.Session() as session:
        try:
            data = fetch_data(session, url, params)
            AQI_FILE.write_text(json.dumps(data, indent=2))
            logger.info("AQI saved.")
        except OSError as e:
            logger.error(f"File error: {e}")
            sys.exit(1)


def get_weather_data(
    api_key: str, lat: float, lon: float, units: Literal["imperial", "metric"]
) -> None:
    """Fetch weather and save to file."""
    CACHE_DIR.mkdir(parents=True, exist_ok=True)

    # url: str = "http://api.openweathermap.org/data/3.0/onecall"

    params = {
        "appid": api_key,
        "lat": lat,
        "lon": lon,
        "units": units,
        "exclude": "minutely,hourly",
    }

    with requests.Session() as session:
        try:
            data = fetch_data(session, ONECALL_URL, params)
            ONECALL_FILE.write_text(json.dumps(data, indent=2))
            logger.info("Weather saved.")
        except OSError as e:
            logger.error(f"File error: {e}")
            sys.exit(1)


def main() -> None:
    parser = argparse.ArgumentParser(description="Weather fetching script.")
    subparsers = parser.add_subparsers(dest="command", required=True)

    getdata_parser = subparsers.add_parser("getdata", help="Fetch Weather data")
    getdata_parser.add_argument(
        "--units",
        choices=["imperial", "metric"],
        default="imperial",
        help="Choose units (imperial = F, metric = C)",
    )

    args = parser.parse_args()

    if args.command == "getdata":
        config = load_config(CONFIG_FILE)

        try:
            lat = float(config["LAT"])
            lon = float(config["LON"])
        except (TypeError, ValueError):
            logger.error("LAT and LON must be numeric in the config file")
            sys.exit(1)

        get_weather_data(config["API_KEY"], lat, lon, args.units)
        get_aqi_data(config["AQI_KEY"], config["AQI_LOC"])
        reload_waybar()


if __name__ == "__main__":
    main()
