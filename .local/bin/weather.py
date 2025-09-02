#!/usr/bin/env python3
import argparse
import json
import requests
import tomllib
from pathlib import Path
from typing import Any, Dict, Literal

# Define paths
HOME = Path.home()
CACHE_DIR = HOME / ".cache" / "weather"
ONECALL_FILE = CACHE_DIR / "onecall.json"
AQI_FILE = CACHE_DIR / "aqidata.json"
CONFIG_FILE = HOME / ".local" / "share" / "location.toml"


def load_config(config_file: Path) -> Dict[str, Any]:
    """Loads configuration from a TOML file."""
    try:
        with config_file.open("rb") as f:
            cfg = tomllib.load(f)
    except FileNotFoundError:
        print(f"Error: Configuration file not found at {config_file}")
        raise SystemExit(1)
    except tomllib.TOMLDecodeError as e:
        print(f"Error decoding TOML file: {e}")
        raise SystemExit(1)

    # Validate required keys
    for k in ("API_KEY", "LAT", "LON"):
        if k not in cfg:
            print(f"Missing required config key: {k}")
            raise SystemExit(1)
    return cfg


def fetch_data(url: str, params: Dict[str, Any]) -> Dict[str, Any]:
    """Fetches data from a URL and returns the JSON response."""
    try:
        response = requests.get(url, params=params, timeout=10)
        response.raise_for_status()
        return response.json()
    except requests.RequestException as e:
        print(f"Error fetching data: {e}")
        raise SystemExit(1)


def get_weather_data(
    api_key: str, lat: float, lon: float, units: Literal["imperial", "metric"]
) -> None:
    """Fetches weather and air quality data and saves it to files."""
    CACHE_DIR.mkdir(parents=True, exist_ok=True)

    base_url: str = "http://api.openweathermap.org/data/"
    urls = {
        "onecall": base_url + "3.0/onecall",
        "air_pollution": base_url + "2.5/air_pollution",
    }
    params = {
        "appid": api_key,
        "lat": lat,
        "lon": lon,
        "units": units,
        "exclude": "minutely,hourly",
    }

    try:
        data = {key: fetch_data(url, params) for key, url in urls.items()}
        ONECALL_FILE.write_text(json.dumps(data["onecall"], indent=2))
        AQI_FILE.write_text(json.dumps(data["air_pollution"], indent=2))

        print("Data successfully fetched and saved.")
    except OSError as e:
        print(f"File error: {e}")
        raise SystemExit(1)


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
