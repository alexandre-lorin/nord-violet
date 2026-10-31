#!/usr/bin/env python3
"""Pin a new terminal to the normal workspace under the pointer."""
import json
import subprocess


def target_workspace(monitors, cursor):
    for monitor in monitors:
        scale = monitor.get("scale", 1) or 1
        width, height = monitor["width"], monitor["height"]
        if monitor.get("transform", 0) % 2:
            width, height = height, width
        if (monitor["x"] <= cursor["x"] < monitor["x"] + width / scale
                and monitor["y"] <= cursor["y"] < monitor["y"] + height / scale):
            return monitor["activeWorkspace"]["id"]
    return next(m["activeWorkspace"]["id"] for m in monitors if m.get("focused"))


def main():
    def read(command):
        return json.loads(subprocess.check_output(["hyprctl", command, "-j"], text=True, timeout=3))
    cursor = read("cursorpos")
    monitors = read("monitors")
    workspace = int(target_workspace(monitors, cursor))
    if workspace <= 0:
        raise ValueError("Bureau normal introuvable")
    monitor = next(m for m in monitors if m["activeWorkspace"]["id"] == workspace)
    # An exec workspace rule alone can leave focus on the other monitor,
    # notably when the target workspace is empty after login.
    subprocess.run(["hyprctl", "dispatch", "focusmonitor", str(monitor["id"])], check=True)
    subprocess.run(["hyprctl", "dispatch", "exec", f"[workspace {workspace}] alacritty --class nvterminal"], check=True)


if __name__ == "__main__":
    main()
