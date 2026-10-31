#!/usr/bin/env python3
"""État matériel compact pour la page Système Nord Violet."""

from __future__ import annotations

import json
from pathlib import Path
import subprocess


def read(path: Path, default=""):
    try:
        return path.read_text(encoding="utf-8").strip()
    except OSError:
        return default


def integer(path: Path, default=0):
    try:
        return int(read(path, str(default)))
    except ValueError:
        return default


def main() -> int:
    supplies = Path("/sys/class/power_supply")
    battery = next(iter(sorted(supplies.glob("BAT*"))), None)
    result = {"present": battery is not None}
    result["model"] = read(Path("/sys/class/dmi/id/product_version"), "—")
    result["cpu"] = next((line.split(":", 1)[1].strip() for line in read(Path("/proc/cpuinfo")).splitlines() if line.startswith("model name")), "—")
    if battery:
        modes = read(battery / "charge_types")
        active_mode = ""
        for token in modes.split():
            if token.startswith("[") and token.endswith("]"):
                active_mode = token[1:-1]
                break
        full = integer(battery / "energy_full")
        design = integer(battery / "energy_full_design")
        health = round(min(100, full * 100 / design)) if design else 0
        result.update({
            "capacity": integer(battery / "capacity"),
            "status": {"Charging": "En charge", "Discharging": "Sur batterie", "Not charging": "Charge arrêtée", "Full": "Pleine"}.get(read(battery / "status"), "Inconnu"),
            "cycles": integer(battery / "cycle_count"),
            "health": health,
            "chargeMode": active_mode or "Standard",
            "limit": 80 if active_mode == "Long_Life" else 100,
        })
    try:
        result["powerProfile"] = subprocess.check_output(["powerprofilesctl", "get"], text=True).strip()
    except (OSError, subprocess.CalledProcessError):
        result["powerProfile"] = "indisponible"
    print(json.dumps(result))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
