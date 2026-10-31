#!/usr/bin/env python3
"""Nord Violet session menu: editorial layout. --preview neutralizes all actions."""
import json
import os
from pathlib import Path
import re
import shlex
import subprocess
import sys


def layout_objects(text):
    decoder = json.JSONDecoder()
    while text.strip():
        item, end = decoder.raw_decode(text.lstrip())
        yield item
        text = text.lstrip()[end:]


def actions(folder, preview=False):
    entries = {entry['label']: entry for entry in layout_objects((folder / 'layout').read_text())}
    titles = [('lock', 'Verrouiller'), ('suspend', 'Mettre en veille'),
              ('logout', 'Se déconnecter'), ('reboot', 'Redémarrer'), ('shutdown', 'Éteindre')]
    result = []
    for ident, title in titles:
        item = entries[ident]
        result.append(dict(id=ident, title=title, key=item['keybind'].upper(),
                           confirm=ident in ('logout', 'reboot'),
                           command=['true'] if preview else shlex.split(item['action'])))
    if len({entry['key'] for entry in result}) != len(result):
        raise ValueError('Les raccourcis de session doivent être distincts.')
    return result


def launch_config(folder, monitors, preview=False):
    monitor = next((m for m in monitors if m.get('focused')), monitors[0])
    accent_file = Path.home() / '.config/quickshell/nord-violet-cc/state/accent'
    accent = accent_file.read_text().strip() if accent_file.is_file() else '#9b7cff'
    if not re.fullmatch(r'#[0-9a-fA-F]{6}', accent):
        accent = '#9b7cff'
    return {'NV_SESSION_MONITOR': monitor['name'], 'NV_SESSION_ACCENT': accent,
            'NV_SESSION_PREVIEW': '1' if preview else '0',
            'NV_SESSION_ACTIONS': json.dumps(actions(folder, preview), ensure_ascii=False)}


def main():
    if any(arg != '--preview' for arg in sys.argv[1:]):
        raise SystemExit('Usage: launch.py [--preview]')
    folder = Path(__file__).resolve().parent
    monitors = json.loads(subprocess.check_output(['hyprctl', 'monitors', '-j'], text=True))
    config = launch_config(folder, monitors, '--preview' in sys.argv)
    os.environ.update(config)
    os.execvp('qs', ['qs', '--no-duplicate', '--path', str(folder / 'editorial.qml')])


if __name__ == '__main__':
    main()
