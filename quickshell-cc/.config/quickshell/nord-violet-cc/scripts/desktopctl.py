#!/usr/bin/env python3
"""Contrôles persistants de la page Bureau Nord Violet."""

from __future__ import annotations

import json
import os
from pathlib import Path
import re
import signal
import subprocess
import sys
import tempfile

GENERAL = Path.home() / ".config/hypr/general.conf"
PRESETS = {"compact": (2, 4), "balanced": (4, 8), "spacious": (8, 16)}


def hypr_option(name: str, field: str, default: int = 0) -> int:
    try:
        data = json.loads(subprocess.check_output(["hyprctl", "getoption", name, "-j"], text=True))
        value = data.get(field, default)
        if field == "custom":
            value = str(value).split()[0]
        return int(value)
    except (OSError, subprocess.CalledProcessError, json.JSONDecodeError, ValueError):
        return default


def waybar_layers() -> int:
    try:
        data = json.loads(subprocess.check_output(["hyprctl", "layers", "-j"], text=True))
    except (OSError, subprocess.CalledProcessError, json.JSONDecodeError):
        return 0
    return sum(1 for monitor in data.values() for level in monitor.get("levels", {}).values()
               for layer in level if "waybar" in str(layer.get("namespace", "")).casefold())


def status() -> int:
    gaps_in = hypr_option("general:gaps_in", "custom", 4)
    gaps_out = hypr_option("general:gaps_out", "custom", 8)
    preset = next((name for name, pair in PRESETS.items() if pair == (gaps_in, gaps_out)), "custom")
    print(json.dumps({"density": preset, "gapsIn": gaps_in, "gapsOut": gaps_out,
                      "rounding": hypr_option("decoration:rounding", "int", 9),
                      "waybarOutputs": waybar_layers()}))
    return 0


def set_density(name: str) -> int:
    if name not in PRESETS:
        print("densité inconnue", file=sys.stderr)
        return 2
    gaps_in, gaps_out = PRESETS[name]
    source = GENERAL.read_text(encoding="utf-8")
    updated, count_in = re.subn(r"(?m)^(\s*gaps_in\s*=\s*)\d+\s*$", rf"\g<1>{gaps_in}", source, count=1)
    updated, count_out = re.subn(r"(?m)^(\s*gaps_out\s*=\s*)\d+\s*$", rf"\g<1>{gaps_out}", updated, count=1)
    if count_in != 1 or count_out != 1:
        print("options gaps_in/gaps_out introuvables", file=sys.stderr)
        return 1
    fd, temporary = tempfile.mkstemp(prefix=".general.", dir=GENERAL.parent)
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as handle:
            handle.write(updated)
        os.replace(temporary, GENERAL)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)
    subprocess.run(["hyprctl", "reload"], check=True, stdout=subprocess.DEVNULL)
    print(name)
    return 0


def signal_waybar(sig: signal.Signals) -> int:
    matched = False
    for entry in Path("/proc").iterdir():
        if not entry.name.isdigit():
            continue
        try:
            if (entry / "comm").read_text().strip() == "waybar":
                os.kill(int(entry.name), sig)
                matched = True
        except (OSError, PermissionError):
            continue
    if not matched:
        print("Waybar n’est pas lancé", file=sys.stderr)
        return 1
    return 0


def main() -> int:
    command = sys.argv[1] if len(sys.argv) > 1 else "status"
    if command == "status":
        return status()
    if command == "density" and len(sys.argv) == 3:
        return set_density(sys.argv[2])
    if command == "bar-toggle":
        return signal_waybar(signal.SIGUSR1)
    if command == "bar-reload":
        return signal_waybar(signal.SIGUSR2)
    print("usage: desktopctl.py {status|density PRESET|bar-toggle|bar-reload}", file=sys.stderr)
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
