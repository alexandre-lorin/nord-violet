#!/usr/bin/env python3
"""Afficher/masquer un flyout sans inverser un état périmé côté QML."""
import json
import subprocess
import sys
import time


def dispatch(*args):
    result = subprocess.run(["hyprctl", "dispatch", *args], capture_output=True, text=True, check=True)
    if result.stdout.strip() != "ok":
        raise RuntimeError(result.stdout.strip() or result.stderr.strip())


def main():
    if len(sys.argv) not in (3, 6, 7) or sys.argv[1] not in ("show", "hide", "position", "position-click") or sys.argv[2] not in ("nvaudio", "nvwifi"):
        raise SystemExit("usage: flyout-workspace.py show|hide NAME | position NAME WIDTH HEIGHT MONITOR | position-click NAME WIDTH HEIGHT X Y")
    action, name = sys.argv[1:3]
    if action in ("show", "hide") and len(sys.argv) != 3:
        raise SystemExit("Arguments invalides")
    if action == "position" and len(sys.argv) != 6:
        raise SystemExit("Arguments de position invalides")
    if action == "position-click" and len(sys.argv) != 7:
        raise SystemExit("Arguments de position invalides")
    monitors = json.loads(subprocess.check_output(["hyprctl", "monitors", "-j"], text=True))
    if action in ("position", "position-click"):
        width, height = map(int, sys.argv[3:5])
        if not (100 <= width <= 2000 and 100 <= height <= 2000):
            raise SystemExit("Dimensions invalides")
        if action == "position-click":
            click_x, click_y = map(float, sys.argv[5:7])
            monitor = next((m for m in monitors
                            if m["x"] <= click_x < m["x"] + m["width"] / m["scale"]
                            and m["y"] <= click_y < m["y"] + m["height"] / m["scale"]), None)
            if monitor is None:
                monitor = next((m for m in monitors if m["focused"]), monitors[0])
        else:
            monitor = next(m for m in monitors if m["name"] == sys.argv[5])
        title = "Nord Violet " + ("Audio" if name == "nvaudio" else "Wifi") + " Flyout"
        clients = json.loads(subprocess.check_output(["hyprctl", "clients", "-j"], text=True))
        client = next(c for c in clients if c["title"] == title)
        address = "address:" + client["address"]
        mw, mh = monitor["width"], monitor["height"]
        if monitor.get("transform", 0) % 2:
            mw, mh = mh, mw
        left = monitor["x"] + 12
        top = monitor["y"] + monitor["reserved"][1] + 12
        right = monitor["x"] + mw / monitor["scale"] - width - 12
        bottom = monitor["y"] + mh / monitor["scale"] - monitor["reserved"][3] - height - 12
        if action == "position-click":
            x = round(max(left, min(click_x - width / 2, right)))
            y = round(max(top, min(click_y - height - 12, bottom)))
        else:
            x = round(right)
            y = round(bottom)
        # La hauteur QML varie après la lecture des sorties/réseaux. La taille
        # physique doit être confirmée avant de révéler le contenu.
        commands = (f"dispatch resizewindowpixel exact {width} {height},{address};"
                    f"dispatch movewindowpixel exact {x} {y},{address}")
        result = subprocess.run(["hyprctl", "--batch", commands], capture_output=True, text=True, check=True)
        if not result.stdout.split() or any(word != "ok" for word in result.stdout.split()):
            raise RuntimeError(result.stdout.strip() or result.stderr.strip())
        for _ in range(30):
            clients = json.loads(subprocess.check_output(["hyprctl", "clients", "-j"], text=True))
            current = next((c for c in clients if c["address"] == client["address"]), None)
            if current and current["at"] == [x, y] and current["size"] == [width, height]:
                return
            time.sleep(0.01)
        raise RuntimeError("La géométrie du popup n'a pas été confirmée")
    focused = next((m for m in monitors if m["focused"]), None)
    shown = next((m for m in monitors if m["specialWorkspace"]["name"] == "special:" + name), None)
    if action == "show":
        if focused is None:
            raise RuntimeError("Aucun moniteur actif")
        if shown is None or shown["name"] != focused["name"]:
            dispatch("togglespecialworkspace", name)
        # Après un rechargement QML, le workspace peut déjà être visible alors
        # que la nouvelle surface n'a jamais reçu le focus (Échap serait perdu).
        title = "Nord Violet " + ("Audio" if name == "nvaudio" else "Wifi") + " Flyout"
        clients = json.loads(subprocess.check_output(["hyprctl", "clients", "-j"], text=True))
        client = next(c for c in clients if c["title"] == title)
        dispatch("focuswindow", "address:" + client["address"])
    elif shown is not None:
        # Sur un autre écran, toggle déplacerait le workspace au lieu de le cacher.
        changed_focus = focused is not None and shown["name"] != focused["name"]
        try:
            if changed_focus:
                dispatch("focusmonitor", shown["name"])
            dispatch("togglespecialworkspace", name)
        finally:
            if changed_focus:
                dispatch("focusmonitor", focused["name"])


if __name__ == "__main__":
    main()
