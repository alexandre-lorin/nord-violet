#!/usr/bin/env python3
"""Luminosité DDC/CI : sélectionner le connecteur, jamais un bus mémorisé."""
import argparse
import json
import re
import subprocess


def bus_for_connector(text, connector):
    bus = None
    valid = False
    for line in text.splitlines():
        if line.strip().startswith("Display "):
            valid = True
            bus = None
        elif line.strip() == "Invalid display":
            valid = False
            bus = None
        match = re.search(r"I2C bus:\s*/dev/i2c-(\d+)", line)
        if match:
            bus = int(match[1])
        match = re.search(r"DRM connector:\s*card\d+-(\S+)", line)
        if match and match[1] == connector and valid and bus is not None:
            return bus
    raise ValueError("Écran DDC/CI non détecté sur " + connector)


def parse_brightness(text):
    match = re.search(r"VCP\s+(?:0x)?10\s+C\s+(\d+)\s+(\d+)", text)
    if not match or int(match[2]) <= 0:
        raise ValueError("Luminosité DDC/CI non prise en charge")
    return int(match[1]), int(match[2])


def run(*args):
    return subprocess.check_output(["ddcutil", *args], text=True, stderr=subprocess.PIPE, timeout=12)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("action", choices=("read", "set"))
    parser.add_argument("connector")
    parser.add_argument("value", type=int, nargs="?")
    args = parser.parse_args()
    if not re.fullmatch(r"(?:HDMI-A|DP)-\d+", args.connector):
        parser.error("Connecteur externe invalide")
    if args.action == "set" and (args.value is None or not 0 <= args.value <= 100):
        parser.error("Luminosité attendue entre 0 et 100")
    try:
        bus = bus_for_connector(run("detect", "--brief"), args.connector)
        current, maximum = parse_brightness(run("--bus", str(bus), "getvcp", "10", "--terse"))
        if args.action == "set":
            run("--bus", str(bus), "setvcp", "10", str(round(args.value * maximum / 100)))
            current, maximum = parse_brightness(run("--bus", str(bus), "getvcp", "10", "--terse"))
        print(json.dumps({"available": True, "connector": args.connector, "percent": round(current * 100 / maximum)}))
        return 0
    except (ValueError, OSError, subprocess.SubprocessError) as error:
        message = str(error) if isinstance(error, ValueError) else "Accès DDC/CI indisponible : vérifier i2c-dev, les droits et le menu de l’écran"
        print(json.dumps({"available": False, "connector": args.connector, "error": message}, ensure_ascii=False))
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
