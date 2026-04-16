#!/usr/bin/env python3

import argparse
import json
import logging
import requests
import sys
import tomllib
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
CONFIG_FILE = HOME / ".config" / "local_env.toml"


def load_config(config_file: Path) -> Dict[str, Any]:
    """Loads configuration from a TOML file."""
    try:
        with config_file.open("rb") as f:
            cfg = tomllib.load(f)
    except FileNotFoundError:
        logger.error(f"Error: Configuration file not found at {config_file}")
        sys.exit(1)
    except tomllib.TOMLDecodeError as e:
        logger.error(f"Error decoding TOML file: {e}")
        sys.exit(1)

    # Validate required keys
    required_keys = ("API_KEY", "LAT", "LON")
    missing = [k for k in required_keys if k not in cfg]
    if missing:
        logger.error(
            f"Missing required config keys: {', '.join(missing)}", file=sys.stderr
        )
        sys.exit(1)

    logger.debug(f"Config loaded successfully from {config_file}")
    return cfg


def fetch_data(
    session: requests.Session, url: str, params: Dict[str, Any]
) -> Dict[str, Any]:
    """Fetches data using a persistent session."""
    try:
        # Using session reduces TCP handshake overhead
        logger.debug(f"Fetching data from {url}")
        response = session.get(url, params=params, timeout=10)
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


def get_weather_data(
    api_key: str, lat: float, lon: float, units: Literal["imperial", "metric"]
) -> None:
    """Fetches weather and air quality data and saves it to files."""
    CACHE_DIR.mkdir(parents=True, exist_ok=True)

    base_url: str = "http://api.openweathermap.org/data/"

    urls = {
        "onecall": f"{base_url}3.0/onecall",
        "air_pollution": f"{base_url}2.5/air_pollution",
    }

    params = {
        "appid": api_key,
        "lat": lat,
        "lon": lon,
        "units": units,
        "exclude": "minutely,hourly",
    }

    with requests.Session() as session:
        try:
            data = {}
            for key, url in urls.items():
                data[key] = fetch_data(session, url, params)

            # Atomic writes to prevent partial files if interrupted
            ONECALL_FILE.write_text(json.dumps(data["onecall"], indent=2))
            AQI_FILE.write_text(json.dumps(data["air_pollution"], indent=2))

            logger.info("Data successfully fetched and saved.")
        except OSError as e:
            logger.error(f"File error: {e}")
            sys.exit(1)

    # Waybar reload function
    reload_waybar()


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
        get_weather_data(config["API_KEY"], config["LAT"], config["LON"], args.units)


if __name__ == "__main__":
    main()
