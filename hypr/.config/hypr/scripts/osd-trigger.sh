#!/usr/bin/env bash
# Contrôle audio commun + notification OSD Nord Violet.
set -euo pipefail

QS=(qs -c nord-violet-cc ipc call)
AUDIO=(python3 /home/toubi/.config/quickshell/nord-violet-cc/scripts/audio-devices.py)

case "${1:-}" in
  volume)
    case "${2:-}" in
      up)   "${AUDIO[@]}" change-volume +5% ;;
      down) "${AUDIO[@]}" change-volume -5% ;;
      mute) "${AUDIO[@]}" toggle-mute ;;
      *) echo "usage: osd-trigger.sh volume up|down|mute" >&2; exit 1 ;;
    esac
    state="$("${AUDIO[@]}" snapshot)"
    default="$(jq -r .default <<<"$state")"
    vol="$(jq -r '.sinks[] | select(.name == $default) | .volume' --arg default "$default" <<<"$state")"
    muted="$(jq -r '.sinks[] | select(.name == $default) | if .muted then "1" else "0" end' --arg default "$default" <<<"$state")"
    "${QS[@]}" osd volume "${vol:-0}" "${muted:-0}"
    ;;

  brightness)
    case "${2:-}" in
      up)   brightnessctl set 5%+ > /dev/null ;;
      down) brightnessctl set 5%- > /dev/null ;;
      *) echo "usage: osd-trigger.sh brightness up|down" >&2; exit 1 ;;
    esac
    cur="$(brightnessctl get)"
    max="$(brightnessctl max)"
    "${QS[@]}" osd brightness "$((cur * 100 / max))"
    ;;

  *)
    echo "usage: osd-trigger.sh volume|brightness ..." >&2
    exit 1
    ;;
esac
