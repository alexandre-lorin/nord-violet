#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 3 ]; then
    echo "usage: stylectl.sh DENSITY CORNERS MOTION" >&2
    exit 1
fi

density="$1"
corners="$2"
motion="$3"

case "$density" in compact|balanced|airy) ;; *) exit 2 ;; esac
case "$corners" in sharp|moderate|soft) ;; *) exit 2 ;; esac
case "$motion" in off|reduced|full) ;; *) exit 2 ;; esac

state_dir="${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/nord-violet-cc/state"
mkdir -p "$state_dir"
temporary="$(mktemp "$state_dir/.style.XXXXXX")"
trap 'rm -f "$temporary"' EXIT
printf '%s %s %s\n' "$density" "$corners" "$motion" > "$temporary"
chmod 0644 "$temporary"
mv -f "$temporary" "$state_dir/style"
trap - EXIT
