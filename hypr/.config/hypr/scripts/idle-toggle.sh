#!/usr/bin/env bash
# Relance l'écran de veille manuel si son processus s'est arrêté.
set -euo pipefail

if qs -c nord-violet-idle ipc call idle toggle >/dev/null 2>&1; then
    exit 0
fi

qs -n -d -c nord-violet-idle
for ((attempt = 0; attempt < 30; attempt++)); do
    if qs -c nord-violet-idle ipc call idle toggle >/dev/null 2>&1; then
        exit 0
    fi
    sleep 0.05
done

echo "Nord Violet Idle : le programme n'a pas répondu après son lancement." >&2
exit 1
