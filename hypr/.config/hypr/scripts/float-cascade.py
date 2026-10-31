#!/usr/bin/env python3
"""Toggle floating; place new floating windows in a bounded cascade."""
import json
import subprocess


def placement(monitor, others):
    scale = monitor.get("scale", 1) or 1
    width, height = monitor["width"], monitor["height"]
    if monitor.get("transform", 0) % 2:
        width, height = height, width
    left, top, right, bottom = monitor.get("reserved", [0, 0, 0, 0])
    x0, y0 = monitor["x"] + left + 12, monitor["y"] + top + 12
    usable_w = max(1, int(width / scale - left - right - 24))
    usable_h = max(1, int(height / scale - top - bottom - 24))
    w, h = min(1000, usable_w), min(650, usable_h)
    max_x, max_y = x0 + usable_w - w, y0 + usable_h - h
    start_x = max(x0, x0 + (usable_w - w) // 2 - 96)
    start_y = max(y0, y0 + (usable_h - h) // 2 - 64)
    candidates = []
    for i in range(24):
        x = min(max_x, start_x + i * 40)
        y = min(max_y, start_y + i * 32)
        if (x, y) not in candidates:
            candidates.append((x, y))
    def separation(point):
        return min((abs(point[0] - win["at"][0]) + abs(point[1] - win["at"][1])
                    for win in others), default=10000)
    point = next((p for p in candidates if separation(p) >= 60),
                 max(candidates, key=separation))
    return w, h, *point


def main():
    def read(command):
        return json.loads(subprocess.check_output(["hyprctl", command, "-j"], text=True, timeout=3))
    active = read("activewindow")
    address = active.get("address")
    if not address:
        return
    target = "address:" + address
    if active.get("floating"):
        subprocess.run(["hyprctl", "dispatch", "togglefloating", target], check=True)
        return
    monitor = next(m for m in read("monitors") if m["id"] == active["monitor"])
    others = [w for w in read("clients") if w.get("floating") and not w.get("hidden")
              and w.get("mapped", True) and w["address"] != address
              and w["workspace"]["id"] == active["workspace"]["id"]]
    w, h, x, y = placement(monitor, others)
    subprocess.run(["hyprctl", "--batch",
                    f"dispatch togglefloating {target}; "
                    f"dispatch resizewindowpixel exact {w} {h},{target}; "
                    f"dispatch movewindowpixel exact {x} {y},{target}"], check=True)


if __name__ == "__main__":
    main()
