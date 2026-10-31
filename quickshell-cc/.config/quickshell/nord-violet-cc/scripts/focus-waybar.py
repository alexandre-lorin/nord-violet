#!/usr/bin/env python3
"""Small JSON adapter; focusctl owns the session and notification state."""
import json
from pathlib import Path
import subprocess


def render(status):
    state, _, seconds = status.strip().partition("|")
    if state not in ("active", "paused"):
        return {"text": "", "tooltip": "", "class": "inactive"}
    remaining = max(0, int(seconds))
    clock = f"{remaining // 60:02d}:{remaining % 60:02d}"
    paused = state == "paused"
    return {
        "text": f"{'Ⅱ' if paused else '◷'} {clock}",
        "class": state,
        "tooltip": f"Focus {'en pause' if paused else 'en cours'} · {clock}\n"
                   "Clic : pause / reprendre · clic droit : arrêter\n"
                   "Clic molette : réglages Profils",
    }


if __name__ == "__main__":
    result = subprocess.run([str(Path(__file__).with_name("focusctl.sh")), "status"],
                            capture_output=True, text=True, timeout=5)
    print(json.dumps(render(result.stdout), ensure_ascii=False))
