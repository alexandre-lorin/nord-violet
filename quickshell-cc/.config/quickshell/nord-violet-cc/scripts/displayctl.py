#!/usr/bin/env python3
"""Réglages d’écran validés contre les modes réellement disponibles."""

from __future__ import annotations

import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile


MONITORS_CONF = Path.home() / ".config/hypr/monitors.conf"


def monitors():
    return json.loads(subprocess.check_output(["hyprctl", "monitors", "-j"], text=True))


def set_rate(name: str, requested: str) -> int:
    rows = monitors()
    monitor = next((row for row in rows if row.get("name") == name), None)
    if not monitor:
        print("écran introuvable", file=sys.stderr)
        return 1
    width, height = int(monitor["width"]), int(monitor["height"])
    native_prefix = f"{width}x{height}@"
    rates = []
    for mode in monitor.get("availableModes", []):
        if mode.startswith(native_prefix):
            try:
                rates.append(float(mode.split("@", 1)[1].removesuffix("Hz")))
            except ValueError:
                pass
    target = float(requested)
    if not any(abs(rate - target) < 0.6 for rate in rates):
        print("taux non pris en charge pour la résolution native", file=sys.stderr)
        return 2

    source = MONITORS_CONF.read_text(encoding="utf-8")
    pattern = rf"(?m)^(monitor\s*=\s*{re.escape(name)}\s*,\s*{width}x{height}@)[0-9.]+(\s*,[^\n]+)$"
    updated, count = re.subn(pattern, rf"\g<1>{requested}\g<2>", source, count=1)
    if count != 1:
        print("ligne du moniteur introuvable dans monitors.conf", file=sys.stderr)
        return 1
    fd, temporary = tempfile.mkstemp(prefix=".monitors.", dir=MONITORS_CONF.parent)
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as handle:
            handle.write(updated)
        os.replace(temporary, MONITORS_CONF)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)
    subprocess.run(["hyprctl", "reload"], check=True, stdout=subprocess.DEVNULL)
    return 0


def main() -> int:
    if len(sys.argv) == 4 and sys.argv[1] == "rate":
        try:
            return set_rate(sys.argv[2], sys.argv[3])
        except (OSError, subprocess.CalledProcessError, json.JSONDecodeError, ValueError) as error:
            print(error, file=sys.stderr)
            return 1
    print("usage: displayctl.py rate MONITOR HZ", file=sys.stderr)
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
