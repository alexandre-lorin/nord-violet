#!/usr/bin/env python3
"""Lecture et écriture sûre des réglages Hyprland exposés dans l’Atelier."""

from __future__ import annotations

import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile


CONFIG = Path.home() / ".config/hypr"


def option(name: str, field: str, default):
    try:
        data = json.loads(subprocess.check_output(["hyprctl", "getoption", name, "-j"], text=True))
        return data.get(field, default)
    except (OSError, subprocess.CalledProcessError, json.JSONDecodeError):
        return default


def status() -> int:
    try:
        version = subprocess.check_output(["hyprctl", "version"], text=True).splitlines()[0]
    except (OSError, subprocess.CalledProcessError, IndexError):
        version = "Hyprland indisponible"
    print(json.dumps({
        "version": version,
        "layout": option("general:layout", "str", "dwindle"),
        "animations": bool(option("animations:enabled", "int", 1)),
        "blur": bool(option("decoration:blur:enabled", "int", 1)),
        "border": int(option("general:border_size", "int", 2)),
    }))
    return 0


def replace(path: Path, pattern: str, replacement: str) -> None:
    source = path.read_text(encoding="utf-8")
    updated, count = re.subn(pattern, replacement, source, count=1)
    if count != 1:
        raise RuntimeError(f"option introuvable dans {path.name}")
    fd, temporary = tempfile.mkstemp(prefix=f".{path.name}.", dir=path.parent)
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as handle:
            handle.write(updated)
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


def apply() -> int:
    subprocess.run(["hyprctl", "reload"], check=True, stdout=subprocess.DEVNULL)
    return 0


def main() -> int:
    command = sys.argv[1] if len(sys.argv) > 1 else "status"
    try:
        if command == "status":
            return status()
        if command == "layout" and len(sys.argv) == 3 and sys.argv[2] in ("dwindle", "master"):
            replace(CONFIG / "general.conf", r"(?m)^(\s*layout\s*=\s*)\w+\s*$", rf"\g<1>{sys.argv[2]}")
            return apply()
        if command == "animations" and len(sys.argv) == 3 and sys.argv[2] in ("on", "off"):
            value = "yes" if sys.argv[2] == "on" else "no"
            replace(CONFIG / "animations.conf", r"(?m)^(\s*enabled\s*=\s*)(?:yes|no)\s*$", rf"\g<1>{value}")
            return apply()
        if command == "blur" and len(sys.argv) == 3 and sys.argv[2] in ("on", "off"):
            value = "yes" if sys.argv[2] == "on" else "no"
            replace(CONFIG / "decoration.conf", r"(?ms)(blur\s*\{.*?^\s*enabled\s*=\s*)(?:yes|no)", rf"\g<1>{value}")
            return apply()
        if command == "border" and len(sys.argv) == 3 and sys.argv[2] in ("0", "2", "3"):
            replace(CONFIG / "general.conf", r"(?m)^(\s*border_size\s*=\s*)\d+\s*$", rf"\g<1>{sys.argv[2]}")
            return apply()
        if command == "reload":
            return apply()
    except (OSError, RuntimeError, subprocess.CalledProcessError) as error:
        print(error, file=sys.stderr)
        return 1
    print("usage: hyprlandctl.py {status|layout MODE|animations on|off|blur on|off|border N|reload}", file=sys.stderr)
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
