#!/usr/bin/env bash
# ~/.config/quickshell/nord-violet-cc/scripts/accentctl.sh
#
# Synchronise uniquement l'accent des composants Nord Violet existants.
# Les autres couleurs restent définies à la main dans chaque palette.
# XDG_CONFIG_HOME désigne les fichiers actifs, y compris avec GNU Stow.

set -euo pipefail

usage() {
    echo "usage: accentctl.sh '#rrggbb'" >&2
    exit 1
}

[ $# -eq 1 ] || usage

hex="$1"
[[ "$hex" =~ ^#[0-9a-fA-F]{6}$ ]] || usage

python3 - "$hex" "${XDG_CONFIG_HOME:-$HOME/.config}" <<'PY'
import os
from pathlib import Path
import re
import stat
import sys
import tempfile

hex_color, config_dir = sys.argv[1:]
root = Path(config_dir)
rgb = hex_color[1:]
updates = []

def replace(relative, pattern, replacement):
    path = root / relative
    if not path.is_file():
        return
    original = path.read_text()
    changed, count = re.subn(pattern, replacement, original, flags=re.MULTILINE)
    if count == 0:
        raise SystemExit(f"Accent introuvable dans {path}; aucun fichier modifié.")
    if changed != original:
        updates.append((path, changed))

replace('waybar/colors.css', r'(@define-color accent )#[0-9a-fA-F]{6}(;)',
        lambda m: m[1] + hex_color + m[2])
replace('hypr/palette.conf', r'^(\$(?:accent|accent_dim|border_active)\s*=\s*0x[0-9a-fA-F]{2})[0-9a-fA-F]{6}',
        lambda m: m[1] + rgb)
replace('hypr/hyprlock.conf', r'(check_color\s*=\s*rgba\()[0-9a-fA-F]{6}(ff\))',
        lambda m: m[1] + rgb + m[2])
replace('mako/config', r'(\[urgency=normal\]\s*\n\s*border-color=)#[0-9a-fA-F]{6}',
        lambda m: m[1] + hex_color)
replace('alacritty/colors.toml', r'^(cursor\s*=\s*")#[0-9a-fA-F]{6}("\s*)$',
        lambda m: m[1] + hex_color + m[2])
replace('gtk-3.0/gtk.css', r'(@define-color accent )#[0-9a-fA-F]{6}(;)',
        lambda m: m[1] + hex_color + m[2])
replace('fuzzel/fuzzel.ini', r'^((?:match|selection-match|border)=)[0-9a-fA-F]{6}(ff)$',
        lambda m: m[1] + rgb + m[2])
replace('wlogout/style.css', r'(border-color:\s*)#[0-9a-fA-F]{6}(;)',
        lambda m: m[1] + hex_color + m[2])

state = root / 'quickshell/nord-violet-cc/state/accent'
updates.append((state, hex_color + '\n'))
for path, content in updates:
    # Remplacer la cible réelle préserve les liens symboliques Stow.
    target = path.resolve()
    target.parent.mkdir(parents=True, exist_ok=True)
    mode = stat.S_IMODE(target.stat().st_mode) if target.exists() else 0o644
    fd, temporary = tempfile.mkstemp(prefix='.' + target.name + '.', dir=target.parent)
    try:
        with os.fdopen(fd, 'w') as output:
            output.write(content)
        os.chmod(temporary, mode)
        os.replace(temporary, target)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)
PY

hyprctl keyword general:col.active_border "rgb(${hex#\#})" >/dev/null 2>&1 || true
makoctl reload >/dev/null 2>&1 || true
pkill -SIGUSR2 -x waybar 2>/dev/null || true
