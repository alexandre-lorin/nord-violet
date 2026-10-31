#!/usr/bin/env python3
"""Falcon scratchpad: one instance, place while hidden, preserve session on hide."""
import argparse
import fcntl
import json
import os
from pathlib import Path
import shlex
import subprocess
import time

CLASS = 'falcon-popup'
SPECIAL = 'nvfalcon'


def hypr(*args):
    result = subprocess.run(['hyprctl', *args], capture_output=True, text=True, timeout=5)
    if result.returncode or result.stdout.strip().lower().startswith(('error', 'invalid')):
        raise RuntimeError(result.stderr.strip() or result.stdout.strip())
    return result.stdout


def query(name):
    return json.loads(hypr(name, '-j'))


def geometry(m):
    w, h = m['width'], m['height']
    if m.get('transform', 0) in (1, 3, 5, 7):
        w, h = h, w
    scale = m.get('scale', 1)
    w, h = round(w / scale), round(h / scale)
    left, top, right, bottom = m.get('reserved', [0, 0, 0, 0])
    usable_w, usable_h = max(1, w - left - right), max(1, h - top - bottom)
    width = min(1400, max(1, round(usable_w * .68)))
    height = min(850, max(1, round(usable_h * .75)))
    x = m['x'] + left + (usable_w - width) // 2
    y = m['y'] + top + (usable_h - height) // 2
    return width, height, x, y


def visible(m):
    return m.get('specialWorkspace', {}).get('name') == 'special:' + SPECIAL


def hide(monitors, target):
    shown = next((m for m in monitors if visible(m)), None)
    if shown:
        # Close on its actual monitor; a toggle on another monitor could reopen it.
        if shown['name'] != target['name']:
            hypr('dispatch', 'focusmonitor', shown['name'])
        hypr('dispatch', 'togglespecialworkspace', SPECIAL)
        if shown['name'] != target['name']:
            hypr('dispatch', 'focusmonitor', target['name'])


def toggle(hide_only=False):
    monitors = query('monitors')
    target = next(m for m in monitors if m['focused'])
    if hide_only or visible(target):
        hide(monitors, target)
        return
    hide(monitors, target)
    clients = query('clients')
    own = next((w for w in clients if w['class'] == CLASS), None)
    if own is None:
        binary = Path.home() / '.local/bin/falcon'
        if not binary.is_file():
            raise RuntimeError('Falcon doit être installé dans ~/.local/bin/falcon.')
        command = shlex.join(['env', 'FALCON_POPUP=1', 'alacritty', '--class', CLASS,
                              '--title', 'Falcon', '-e', str(binary), '--no-boot'])
        hypr('dispatch', 'exec', command)
        for _ in range(60):
            own = next((w for w in query('clients') if w['class'] == CLASS), None)
            if own:
                break
            time.sleep(.05)
        if own is None:
            raise RuntimeError('La fenêtre Falcon ne s’est pas ouverte.')
    address = 'address:' + own['address']
    width, height, x, y = geometry(target)
    hypr('dispatch', 'movetoworkspacesilent', f'special:{SPECIAL},{address}')
    hypr('dispatch', 'moveworkspacetomonitor', f'special:{SPECIAL} {target["name"]}')
    hypr('dispatch', 'setfloating', address)
    hypr('dispatch', 'resizewindowpixel', f'exact {width} {height},{address}')
    hypr('dispatch', 'movewindowpixel', f'exact {x} {y},{address}')
    # Wait for the client/compositor to acknowledge geometry before revealing it.
    for _ in range(40):
        own = next((w for w in query('clients') if w['address'] == own['address']), None)
        if own is None:
            raise RuntimeError('Falcon a quitté pendant son ouverture.')
        actual = (*own['size'], *own['at'])
        if all(abs(a - b) <= 2 for a, b in zip(actual, (width, height, x, y))):
            break
        time.sleep(.025)
    else:
        raise RuntimeError('Position de Falcon non confirmée ; fenêtre conservée masquée.')
    hypr('dispatch', 'togglespecialworkspace', SPECIAL)
    hypr('dispatch', 'focuswindow', address)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--hide', action='store_true')
    args = parser.parse_args()
    os.umask(0o077)
    state = Path(os.environ.get('XDG_STATE_HOME', str(Path.home() / '.local/state'))) / 'falcon'
    state.mkdir(parents=True, exist_ok=True)
    with (state / 'popup.lock').open('w') as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            return
        toggle(args.hide)


if __name__ == '__main__':
    try:
        main()
    except (RuntimeError, subprocess.SubprocessError, OSError, StopIteration) as error:
        raise SystemExit(f'Falcon : {error}')
