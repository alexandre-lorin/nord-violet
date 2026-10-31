#!/usr/bin/env bash
set -euo pipefail

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/nord-violet"
state_file="$state_dir/profile"

if [[ "${1:-}" == "status" ]]; then
    if [[ -r "$state_file" ]]; then
        read -r profile < "$state_file"
        case "$profile" in
            work|mobile|game|night) printf '%s\n' "$profile" ;;
            *) printf 'custom\n' ;;
        esac
    else
        printf 'custom\n'
    fi
    exit 0
fi

profile="${1:-}"
case "$profile" in
    work)
        power="balanced"; brightness="75%"; dnd="off"; vrr="0"; label="Travail"
        ;;
    mobile)
        power="power-saver"; brightness="50%"; dnd="off"; vrr="0"; label="Nomade"
        ;;
    game)
        power="performance"; brightness="100%"; dnd="on"; vrr="2"; label="Jeu"
        ;;
    night)
        power="power-saver"; brightness="25%"; dnd="on"; vrr="0"; label="Nuit"
        ;;
    *)
        printf 'usage: %s {status|work|mobile|game|night}\n' "$0" >&2
        exit 2
        ;;
esac

command -v powerprofilesctl >/dev/null
command -v brightnessctl >/dev/null
command -v makoctl >/dev/null
command -v hyprctl >/dev/null

powerprofilesctl set "$power"
brightnessctl --quiet set "$brightness"
if [[ "$dnd" == "on" ]]; then
    makoctl mode -a dnd
else
    makoctl mode -r dnd
fi
hyprctl keyword misc:vrr "$vrr" >/dev/null

mkdir -p "$state_dir"
temporary="$(mktemp "$state_dir/.profile.XXXXXX")"
printf '%s\n' "$profile" > "$temporary"
mv -f "$temporary" "$state_file"
printf '%s|Profil %s appliqué\n' "$profile" "$label"
