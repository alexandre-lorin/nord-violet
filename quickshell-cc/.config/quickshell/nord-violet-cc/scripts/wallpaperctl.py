#!/usr/bin/env python3
"""Apply and persist a Nord Violet wallpaper without shell interpolation."""

from __future__ import annotations

import os
from pathlib import Path
import random
import re
import shutil
import subprocess
import sys
import tempfile


WALL_DIR = Path(os.environ.get("NORD_VIOLET_WALL_DIR", "/home/toubi/.config/hypr/wallpaper")).resolve()
CONFIG = Path(os.environ.get("NORD_VIOLET_HYPRPAPER_CONFIG", "/home/toubi/.config/hypr/hyprpaper.conf"))
EXTENSIONS = {".png", ".jpg", ".jpeg", ".webp"}


def fail(message: str) -> int:
    print(message, file=sys.stderr)
    return 2


def safe_image(raw: str) -> Path:
    path = Path(raw).expanduser().resolve(strict=True)
    if not path.is_file() or path.suffix.lower() not in EXTENSIONS:
        raise ValueError("format d'image non pris en charge")
    if path != WALL_DIR and WALL_DIR not in path.parents:
        raise ValueError("le fichier doit être dans ~/.config/hypr/wallpaper")
    return path


def source_image(raw: str) -> Path:
    path = Path(raw).expanduser().resolve(strict=True)
    if not path.is_file() or path.suffix.lower() not in EXTENSIONS:
        raise ValueError("format d'image non pris en charge")
    return path


def available_images() -> list[Path]:
    return sorted(
        path.resolve()
        for path in WALL_DIR.iterdir()
        if path.is_file() and path.suffix.lower() in EXTENSIONS
    )


def import_image(raw: str) -> Path:
    source = source_image(raw)
    if source == WALL_DIR or WALL_DIR in source.parents:
        return source
    WALL_DIR.mkdir(parents=True, exist_ok=True)
    target = WALL_DIR / source.name
    counter = 2
    while target.exists():
        target = WALL_DIR / f"{source.stem}-{counter}{source.suffix.lower()}"
        counter += 1
    shutil.copy2(source, target)
    return target.resolve()


def update_config(path: Path, monitor: str) -> None:
    original = CONFIG.read_text(encoding="utf-8")
    lines = original.splitlines(keepends=True)
    output: list[str] = []
    in_block = False
    block_monitor = ""
    block: list[str] = []

    def flush() -> None:
        nonlocal block
        selected = monitor == "all" or block_monitor == monitor
        if selected:
            block = [
                re.sub(r"^(\s*path\s*=\s*).*$", rf"\g<1>{path}", line)
                if re.match(r"^\s*path\s*=", line)
                else line
                for line in block
            ]
        output.extend(block)
        block = []

    for line in lines:
        if not in_block and re.match(r"^\s*wallpaper\s*\{", line):
            in_block = True
            block_monitor = ""
            block = [line]
            continue
        if in_block:
            block.append(line)
            match = re.match(r"^\s*monitor\s*=\s*(.*?)\s*$", line)
            if match:
                block_monitor = match.group(1)
            if re.match(r"^\s*}\s*$", line):
                flush()
                in_block = False
            continue
        if monitor == "all" and re.match(r"^\s*preload\s*=", line):
            line = re.sub(r"^(\s*preload\s*=\s*).*$", rf"\g<1>{path}", line)
        output.append(line)

    if block:
        flush()

    data = "".join(output)
    CONFIG.parent.mkdir(parents=True, exist_ok=True)
    fd, temp_name = tempfile.mkstemp(prefix="hyprpaper.", suffix=".conf", dir=CONFIG.parent)
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as handle:
            handle.write(data)
        os.chmod(temp_name, CONFIG.stat().st_mode)
        os.replace(temp_name, CONFIG)
    finally:
        if os.path.exists(temp_name):
            os.unlink(temp_name)


def apply_runtime(path: Path, monitor: str) -> None:
    target = "" if monitor == "all" else monitor
    result = subprocess.run(
        ["hyprctl", "hyprpaper", "reload", f"{target},{path}"],
        check=False,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    if result.returncode != 0:
        subprocess.Popen(
            ["hyprpaper"],
            stdin=subprocess.DEVNULL,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            start_new_session=True,
        )


def main() -> int:
    if len(sys.argv) < 2:
        return fail("usage: wallpaperctl.py IMAGE [all|MONITOR] | random [MONITOR] | import FILE")

    action = sys.argv[1]
    if action == "import":
        if len(sys.argv) != 3:
            return fail("usage: wallpaperctl.py import FILE")
        try:
            print(import_image(sys.argv[2]))
        except (OSError, ValueError) as exc:
            return fail(str(exc))
        return 0

    monitor = sys.argv[2] if len(sys.argv) == 3 else "all"
    if monitor != "all" and not re.fullmatch(r"[A-Za-z0-9_.-]+", monitor):
        return fail("nom de moniteur invalide")
    try:
        if action == "random":
            images = available_images()
            if not images:
                raise ValueError("aucun fond d'écran disponible")
            path = random.choice(images)
        else:
            path = safe_image(action)
        update_config(path, monitor)
        apply_runtime(path, monitor)
    except (OSError, ValueError) as exc:
        return fail(str(exc))
    print(path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
