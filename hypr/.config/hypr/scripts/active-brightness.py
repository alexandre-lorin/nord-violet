#!/usr/bin/env python3
"""Molette RK : luminosité de l'écran focalisé, crans DDC regroupés."""
import argparse
import fcntl
import importlib.util
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import time


def command(*args):
    return subprocess.check_output(args, text=True, stderr=subprocess.PIPE, timeout=15)


def focused_connector(monitors):
    monitor = next((item for item in monitors if item.get("focused")), None)
    if not monitor or not re.fullmatch(r"(?:eDP|LVDS|HDMI-A|DP)-\d+", monitor["name"]):
        raise ValueError("Aucun écran compatible focalisé")
    return monitor["name"]


def target_percent(current, delta, internal=False):
    return max(1 if internal else 0, min(100, current + delta))


def drain(stream):
    stream.seek(0)
    delta = int(stream.read() or "0")
    stream.seek(0)
    stream.truncate()
    stream.flush()
    return delta


class Brightness:
    def __init__(self, connector):
        self.internal = connector.startswith(("eDP-", "LVDS-"))
        if self.internal:
            devices = sorted(Path("/sys/class/backlight").iterdir())
            if not devices:
                raise ValueError("Rétroéclairage interne indisponible")
            self.device = devices[0].name
            self.maximum = int(command("brightnessctl", "-d", self.device, "max"))
            current = int(command("brightnessctl", "-d", self.device, "get"))
        else:
            path = Path.home() / ".config/quickshell/nord-violet-cc/scripts/monitor-brightness.py"
            spec = importlib.util.spec_from_file_location("monitor_brightness", path)
            self.ddc = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(self.ddc)
            runtime = Path(os.environ.get("XDG_RUNTIME_DIR", "/run/user/" + str(os.getuid()))) / "nord-violet-brightness"
            cache = runtime / (connector + ".bus")
            try:
                cached = json.loads(cache.read_text())
                if time.time() - cached["time"] > 30:
                    raise ValueError("Cache expiré")
                self.bus = int(cached["bus"])
            except (OSError, ValueError, KeyError, TypeError):
                self.bus = self.ddc.bus_for_connector(self.ddc.run("detect", "--brief"), connector)
                cache.write_text(json.dumps({"bus": self.bus, "time": time.time()}))
            current, self.maximum = self.ddc.parse_brightness(
                self.ddc.run("--bus", str(self.bus), "getvcp", "10", "--terse"))
        if self.maximum <= 0:
            raise ValueError("Luminosité maximale invalide")
        self.percent = round(current * 100 / self.maximum)

    def change(self, delta):
        target = target_percent(self.percent, delta, self.internal)
        if self.internal:
            command("brightnessctl", "-d", self.device, "set", str(target) + "%")
            actual = int(command("brightnessctl", "-d", self.device, "get"))
            self.percent = round(actual * 100 / self.maximum)
        else:
            # Éviter la relecture automatique après CHAQUE écriture ; la lecture
            # initiale reste réelle, avec les temporisations DDC standard.
            self.ddc.run("--bus", str(self.bus), "--noverify", "setvcp", "10", str(round(target * self.maximum / 100)))
            self.percent = target


def change_focused(delta):
    connector = focused_connector(json.loads(command("hyprctl", "monitors", "-j")))
    runtime = Path(os.environ.get("XDG_RUNTIME_DIR", "/run/user/" + str(os.getuid()))) / "nord-violet-brightness"
    runtime.mkdir(mode=0o700, exist_ok=True)
    # Deux verrous : protéger la somme des crans et élire un seul worker.
    # Libérer le worker sous le verrou de somme évite de perdre le dernier cran.
    with (runtime / (connector + ".queue")).open("a+") as queue_lock, \
         (runtime / (connector + ".worker")).open("a+") as worker, \
         (runtime / (connector + ".pending")).open("a+") as pending:
        fcntl.flock(queue_lock, fcntl.LOCK_EX)
        total = drain(pending) + delta
        pending.write(str(total))
        pending.flush()
        try:
            fcntl.flock(worker, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            return
        fcntl.flock(queue_lock, fcntl.LOCK_UN)
        try:
            brightness = Brightness(connector)
            idle_until = time.monotonic() + 0.7
            while True:
                time.sleep(0.04)
                fcntl.flock(queue_lock, fcntl.LOCK_EX)
                batch = drain(pending)
                if not batch:
                    if time.monotonic() >= idle_until:
                        return
                    fcntl.flock(queue_lock, fcntl.LOCK_UN)
                    continue
                fcntl.flock(queue_lock, fcntl.LOCK_UN)
                brightness.change(batch)
                idle_until = time.monotonic() + 0.7
        finally:
            fcntl.flock(queue_lock, fcntl.LOCK_EX)
            drain(pending)
            fcntl.flock(worker, fcntl.LOCK_UN)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("delta", type=int, choices=(-5, 5))
    args = parser.parse_args()
    try:
        change_focused(args.delta)
    except (OSError, ValueError, subprocess.SubprocessError) as error:
        subprocess.run(["notify-send", "Luminosité indisponible",
                        "Vérifiez DDC/CI et i2c-dev pour l'écran externe. Aucun autre écran n'a été modifié."],
                       check=False, timeout=3)
        print(str(error), file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
