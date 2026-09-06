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
    except FileNotFoundError:
        raise RuntimeError(f"Config file not found: {CONFIG_FILE}")
    except json.JSONDecodeError as e:
        raise RuntimeError(f"Invalid JSON in config: {e}")

    aqicn = config.get("aqicn", {})
    meteo = config.get("open-meteo", {})

    missing = []
    if not aqicn.get("token") or not aqicn.get("city") or not aqicn.get("url"):
        missing.append("aqicn.{url,token,city}")
    if not meteo.get("latitude") or not meteo.get("longitude"):
        missing.append("open-meteo.{latitude,longitude}")
    if missing:
        raise RuntimeError(f"Missing config keys: {', '.join(missing)}")

    return {
        "aqicn": aqicn,
        "open-meteo": meteo,
        "cache_dir": Path(config.get("cache_dir", HOME / ".cache" / "weather")),
    }


def write_cache(path: Path, data: dict) -> None:
    """Atomic write"""
    tmp = path.with_suffix(".tmp")
    tmp.write_text(json.dumps(data, indent=2))
    tmp.replace(path)


def fetch_json(url: str, params: dict) -> dict:
    """GET and validate a JSON response"""
    try:
        response = requests.get(url, params=params, timeout=10)
        response.raise_for_status()
        return response.json()
    except requests.HTTPError as e:
        raise RuntimeError(f"Request failed for {url}: {e}")


def fetch_aqi(cfg: dict, cache_dir: Path) -> None:
    """Fetch AQI data and save to cache."""
    data = fetch_json(cfg["url"].format(city=cfg["city"]), {"token": cfg["token"]})

    if data.get("status") != "ok":
        raise RuntimeError(
            f"AQICN API returned '{data.get('status')}': {data.get('data')}"
        )

    write_cache(cache_dir / "aqidata.json", data)
    logger.info("AQICN data saved")


def fetch_open_meteo(cfg: dict, cache_dir: Path) -> None:
    """Fetch Open-Meteo data and save to cache."""
    params = {
        "latitude": cfg["latitude"],
        "longitude": cfg["longitude"],
        "current": [
            "temperature_2m",
            "relative_humidity_2m",
            "apparent_temperature",
            "weather_code",
            "cloud_cover",
            "precipitation",
            "wind_speed_10m",
        ],
        "timezone": "auto",
        "forecast_days": 1,
        "wind_speed_unit": "mph",
        "temperature_unit": "fahrenheit",
        "precipitation_unit": "inch",
    }
    data = fetch_json(cfg["url"], params)

    if data.get("error"):
        raise RuntimeError(
            f"Open-Meteo API error: '{data.get('reason')}': {data.get('unknown')}"
        )

    write_cache(cache_dir / "open-meteo.json", data)
    logger.info("Open-Meteo data saved")


def main() -> int:
    try:
        config = load_config()
    except RuntimeError as e:
        logger.error(str(e))
        return 1

    failures = 0
    for name, fn, cfg in (
        ("aqicn", fetch_aqi, config["aqicn"]),
        ("open-meteo", fetch_open_meteo, config["open-meteo"]),
    ):
        try:
            fn(cfg, config["cache_dir"])
        except RuntimeError as e:
            logger.error("%s fetch failed: %s", name, e)
            failures += 1

    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
