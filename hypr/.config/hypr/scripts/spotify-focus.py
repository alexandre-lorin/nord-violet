#!/usr/bin/env python3
"""Afficher Spotify s'il tourne déjà, sinon le lancer puis lui donner le focus."""
import json
import subprocess
import time


def spotify_address(clients):
    return next((client["address"] for client in clients
                 if client.get("class", "").lower() == "spotify"
                 and client.get("mapped", True) and client.get("address")), None)


def find():
    return spotify_address(json.loads(subprocess.check_output(
        ["hyprctl", "clients", "-j"], text=True, timeout=3)))


def main():
    address = find()
    if not address:
        subprocess.Popen(["gtk-launch", "spotify"], start_new_session=True,
                         stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        for _ in range(60):
            time.sleep(0.1)
            address = find()
            if address:
                break
    if address:
        subprocess.run(["hyprctl", "dispatch", "focuswindow", "address:" + address],
                       check=True, stdout=subprocess.DEVNULL, timeout=3)
        return 0
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
