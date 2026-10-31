#!/usr/bin/env bash
# ~/.config/quickshell/nord-violet-cc/scripts/sysstat.sh
#
# Appelé par PerformancePage.qml (Process, argv only, sans argument —
# même convention que les autres scripts du projet). Imprime des paires
# clé=valeur, une par ligne, faciles à parser côté QML sans dépendance
# JSON. Ne touche à rien, lecture seule uniquement.
#
# CPU%/RAM% : lus depuis /proc, garantis présents sur n'importe quel
# Linux, aucune dépendance externe.
# GPU/VRAM/temp : nvidia-smi (paquet nvidia-utils), absent -> valeurs à
# -1, la page QML doit gérer cette valeur comme "non disponible".

set -euo pipefail

# -- CPU% : delta sur 200ms entre deux lectures de /proc/stat --------
read -r _ u1 n1 s1 i1 w1 irq1 sirq1 _ < /proc/stat
sleep 0.2
read -r _ u2 n2 s2 i2 w2 irq2 sirq2 _ < /proc/stat

idle1=$((i1 + w1)); idle2=$((i2 + w2))
total1=$((u1 + n1 + s1 + i1 + w1 + irq1 + sirq1))
total2=$((u2 + n2 + s2 + i2 + w2 + irq2 + sirq2))
totald=$((total2 - total1))
idled=$((idle2 - idle1))

cpu_pct=0
if [ "$totald" -gt 0 ]; then
    cpu_pct=$(( (100 * (totald - idled)) / totald ))
fi

# -- RAM% : MemAvailable est plus fiable que MemFree (tient compte du
# cache récupérable) -------------------------------------------------
mem_total=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
mem_avail=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)
mem_pct=0
if [ "$mem_total" -gt 0 ]; then
    mem_pct=$(( 100 * (mem_total - mem_avail) / mem_total ))
fi

# -- GPU/VRAM/temp (NVIDIA uniquement) --------------------------------
gpu_pct=-1
gpu_temp=-1
vram_pct=-1

if command -v nvidia-smi >/dev/null 2>&1; then
    line=$(nvidia-smi --query-gpu=utilization.gpu,temperature.gpu,memory.used,memory.total \
                       --format=csv,noheader,nounits 2>/dev/null | head -n1 | tr -d ' ')
    if [ -n "$line" ]; then
        gpu_pct=$(echo "$line" | cut -d',' -f1)
        gpu_temp=$(echo "$line" | cut -d',' -f2)
        vram_used=$(echo "$line" | cut -d',' -f3)
        vram_total=$(echo "$line" | cut -d',' -f4)
        if [ -n "${vram_total:-}" ] && [ "$vram_total" -gt 0 ] 2>/dev/null; then
            vram_pct=$(( 100 * vram_used / vram_total ))
        fi
    fi
fi

printf 'cpu=%s\nram=%s\ngpu=%s\ngputemp=%s\nvram=%s\n' \
    "$cpu_pct" "$mem_pct" "$gpu_pct" "$gpu_temp" "$vram_pct"
