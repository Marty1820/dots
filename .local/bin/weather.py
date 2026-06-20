#!/usr/bin/env python3

# pacman -S python-requests

import argparse
import json
import logging
import requests
import sys
import subprocess
import signal
from pathlib import Path
from typing import Any, Dict, Literal, Optional, TypedDict

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


# --- Type Definitions ---


class ProcessedConfig(TypedDict):
    LAT: str
    LON: str
    APPID: str
    AQI_KEY: str
    AQI_LOC: str


def load_config(config_file: Path) -> ProcessedConfig:
    """Loads configuration from a JSON file and validates structure."""
    try:
        with config_file.open("r") as f:
            raw_cfg: Dict[str, Any] = json.load(f)
    except FileNotFoundError:
        logger.error(f"Error: Configuration file not found at {config_file}")
        sys.exit(1)
    except json.JSONDecodeError as e:
        logger.error(f"Error decoding JSON file: {e}")
        sys.exit(1)

    openweather = raw_cfg.get("openweather")
    aqicn = raw_cfg.get("aqicn")

    # Validate required keys
    if (
        not isinstance(openweather, dict)
        or "appid" not in openweather
        or "lat" not in openweather
        or "lon" not in openweather
    ):
        logger.error("Missing 'openweather.keys' in config")
        sys.exit(1)
    if not isinstance(aqicn, dict) or "token" not in aqicn or "city" not in aqicn:
        logger.error("Missing 'aqicn.token|city' in config")
        sys.exit(1)

    logger.debug(f"Config loaded successfully from {config_file}")

    cfg: ProcessedConfig = {
        "LAT": str(openweather["lat"]),
        "LON": str(openweather["lon"]),
        "APPID": str(openweather["appid"]),
        "AQI_KEY": str(aqicn["token"]),
        "AQI_LOC": str(aqicn["city"]),
    }
    return cfg


def fetch_data(
    session: requests.Session, url: str, params: Optional[Dict[str, Any]] = None
) -> Dict[str, Any]:
    """
    Fetches data using a persistent session.
    Returns the parsed JSON response.
    """
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
        if rt_signal > signal.SIGRTMAX:
            logger.warning(
                f"Real-time signal {rt_signal} exceeds MAX ({signal.SIGRTMAX}), skipping."
            )
            return

        subprocess.run(
            ["pkill", f"-{rt_signal}", "waybar"], check=False, capture_output=True
        )
        logger.info(f"Waybar reloaded (Signal {rt_signal})")
    except Exception as e:
        logger.warning(f"Failed to send signal to waybar: {e}")


def get_aqi_data(token: str, city: str) -> Optional[Dict[str, Any]]:
    """
    Fetch AQI and save to file.
    Returns the datae dict if successful, None if saved (or exits on fail)
    """
    CACHE_DIR.mkdir(parents=True, exist_ok=True)

    url = AQI_BASE.format(city=city)
    params: Dict[str, Any] = {"token": token}

    with requests.Session() as session:
        try:
            data = fetch_data(session, url, params)
            AQI_FILE.write_text(json.dumps(data, indent=2))
            logger.info("AQI saved.")
            return data
        except OSError as e:
            logger.error(f"File error: {e}")
            sys.exit(1)
        except requests.RequestException:
            return None


def get_weather_data(
    appid: str, lat: float, lon: float, units: Literal["imperial", "metric"]
) -> Optional[Dict[str, Any]]:
    """
    Fetch weather and save to file.
    Returns the data dict if successful
    """
    CACHE_DIR.mkdir(parents=True, exist_ok=True)

    params: Dict[str, Any] = {
        "lat": lat,
        "lon": lon,
        "appid": appid,
        "exclude": "minutely,hourly",
        "units": units,
        "lang": "en",
    }

    with requests.Session() as session:
        try:
            data = fetch_data(session, ONECALL_URL, params)
            ONECALL_FILE.write_text(json.dumps(data, indent=2))
            logger.info("Weather saved.")
            return data
        except OSError as e:
            logger.error(f"File error: {e}")
            sys.exit(1)
        except requests.RequestException:
            return None


def main() -> None:
    parser = argparse.ArgumentParser(description="Weather fetching script.")
    subparsers = parser.add_subparsers(dest="command", required=True)

    getdata_parser = subparsers.add_parser(
        "getdata", help="Fetch Weather data (--units: imperial=󰔅, metric=󰔄)"
    )
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

        get_weather_data(config["APPID"], lat, lon, args.units)
        get_aqi_data(config["AQI_KEY"], config["AQI_LOC"])

        reload_waybar()


if __name__ == "__main__":
    main()
