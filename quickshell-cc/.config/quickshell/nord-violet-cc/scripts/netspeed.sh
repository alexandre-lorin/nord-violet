#!/usr/bin/env bash
set -euo pipefail
iface="${1:-}"
[ -z "$iface" ] && { echo "0	0"; exit 0; }
rx="$(cat "/sys/class/net/$iface/statistics/rx_bytes" 2>/dev/null || echo 0)"
tx="$(cat "/sys/class/net/$iface/statistics/tx_bytes" 2>/dev/null || echo 0)"
printf '%s\t%s\n' "$rx" "$tx"
