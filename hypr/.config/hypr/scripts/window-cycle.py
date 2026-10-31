#!/usr/bin/env python3
"""Parcourir les applications entre bureaux, sans les surfaces du shell."""
import argparse
import json
import subprocess


def next_window(clients, active, reverse=False):
    windows = [c for c in clients if c.get("address") and c.get("mapped", True)
               and not c.get("hidden", False)
               and c.get("workspace", {}).get("id", -1) > 0
               and not c.get("workspace", {}).get("name", "").startswith("special:")
               and not c.get("title", "").startswith("Nord Violet ")]
    if not windows:
        return None
    addresses = [c["address"] for c in windows]
    if active not in addresses:
        return addresses[-1 if reverse else 0]
    return addresses[(addresses.index(active) + (-1 if reverse else 1)) % len(addresses)]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--reverse", action="store_true")
    args = parser.parse_args()
    def read(kind):
        return json.loads(subprocess.check_output(["hyprctl", kind, "-j"], text=True, timeout=3))
    target = next_window(read("clients"), read("activewindow").get("address"), args.reverse)
    if target:
        subprocess.run(["hyprctl", "dispatch", "focuswindow", "address:" + target], check=True,
                       stdout=subprocess.DEVNULL, timeout=3)


if __name__ == "__main__":
    main()
