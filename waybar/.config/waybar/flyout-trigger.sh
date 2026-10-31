#!/usr/bin/env bash
# ~/.config/waybar/flyout-trigger.sh
# Transmet le point de clic ; le flyout s'ancre sur cet écran précis.
set -euo pipefail

target="$1"  # "audio" ou "wifi"

pos="$(hyprctl cursorpos)"          # format : "X, Y"
x="$(echo "$pos" | cut -d',' -f1 | tr -d ' ')"
y="$(echo "$pos" | cut -d',' -f2 | tr -d ' ')"

qs -c nord-violet-cc ipc call flyout "$target" "$x" "$y"
