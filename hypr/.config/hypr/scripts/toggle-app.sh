#!/bin/bash
# Toggle un special workspace, lance l'appli si absente, re-route sur le
# moniteur focus. Position : "center" (défaut) ou "bottom" (dropdown collé
# en bas, waybar 34px compensée).
#
# Fix du 22/08 : repositionnement AVANT le toggle (fenêtre encore cachée,
# donc pas de flash cross-écran) MAIS regroupé en 2 --batch distincts au
# lieu de dispatches hyprctl séquentiels — c'était ça qui cassait le toggle,
# pas la logique de réordonnancement.
#
# Usage: toggle-app.sh <special> <class> <launch_cmd> [center|bottom]

SPECIAL="$1"
CLASS="$2"
LAUNCH_CMD="$3"
POSITION="${4:-center}"

MON_JSON=$(hyprctl monitors -j | python3 -c "
import json, sys
for m in json.load(sys.stdin):
    if m['focused']:
        print(json.dumps(m))
")
MON_NAME=$(echo "$MON_JSON" | python3 -c "import json,sys;print(json.load(sys.stdin)['name'])")

# Intention capturée AVANT toute modification : si le special est déjà
# affiché sur ce moniteur, l'utilisateur veut le fermer, sinon l'ouvrir.
# Nécessaire car l'évacuation ci-dessous peut elle-même changer l'état de
# visibilité en effet de bord -> togglespecialworkspace en aveugle en fin de
# script se retrouverait à toggler depuis le mauvais état de départ.
INITIAL_SPECIAL=$(echo "$MON_JSON" | python3 -c "import json,sys;print(json.load(sys.stdin)['specialWorkspace']['name'])")
if [ "$INITIAL_SPECIAL" = "special:$SPECIAL" ]; then
    WANT_VISIBLE=0
else
    WANT_VISIBLE=1
fi

# --- Évacuation des fenêtres égarées (fix 22/08) ---
# Si une fenêtre normale (Firefox, etc.) est drag-déposée sur un moniteur
# pendant que le special workspace y est affiché, Hyprland la reparente
# dans le special au lieu du workspace normal du moniteur -> elle se
# retrouve piégée et disparaît au toggle suivant. On la vire systématiquement
# avant de toucher au special, à chaque appel (open ET close), donc le bug
# ne peut plus jamais coincer une fenêtre pour de bon.
ACTIVE_WS=$(echo "$MON_JSON" | python3 -c "import json,sys;print(json.load(sys.stdin)['activeWorkspace']['id'])")
hyprctl clients -j | python3 -c "
import json, sys
for c in json.load(sys.stdin):
    if c['workspace']['name'] == 'special:$SPECIAL' and c['class'] != '$CLASS':
        print(c['address'])
" | while read -r addr; do
    hyprctl dispatch movetoworkspace "$ACTIVE_WS,address:$addr"
done

RUNNING=$(hyprctl clients -j | python3 -c "
import json, sys
for c in json.load(sys.stdin):
    if c['class'] == '$CLASS':
        print('yes'); break
")

if [ -z "$RUNNING" ]; then
    nohup $LAUNCH_CMD >/dev/null 2>&1 &
    for i in $(seq 1 50); do
        sleep 0.1
        FOUND=$(hyprctl clients -j | python3 -c "
import json, sys
for c in json.load(sys.stdin):
    if c['class'] == '$CLASS':
        print('yes'); break
")
        [ -n "$FOUND" ] && break
    done
fi

# --- Batch 1 : tout recalculer AVANT de rendre visible (fenêtre encore cachée) ---
# NB : "dispatch centerwindow" n'accepte PAS de sélecteur de classe, il agit
# sur la fenêtre active/focus. Une fenêtre qui vient d'atterrir sur un special
# workspace n'est jamais "active" -> centerwindow échoue toujours en silence
# ("No floating window found"). Donc même logique que "bottom" partout :
# resize + move avec sélecteur class:^($CLASS)$ explicite.
if [ "$POSITION" = "bottom" ]; then
    read -r W H X Y <<< "$(echo "$MON_JSON" | python3 -c "
import json, sys
m = json.load(sys.stdin)
# reserved = [left, top, right, bottom] en pixels réels réservés par les
# layer surfaces (waybar). Avant : 34 en dur, ne correspondait pas à la
# vraie valeur (42 sur eDP-1) -> le terminal mordait sur la waybar.
reserved_bottom = m['reserved'][3]
GAP = 10  # marge visuelle entre le terminal et la waybar, collage exact = moche
w = int(m['width'] * 0.55)
h = int(m['height'] * 0.45)
x = m['x'] + (m['width'] - w) // 2
y = m['y'] + m['height'] - h - reserved_bottom - GAP
print(w, h, x, y)
")"
else
    read -r W H X Y <<< "$(echo "$MON_JSON" | python3 -c "
import json, sys
m = json.load(sys.stdin)
w = int(m['width'] * 0.6)
h = int(m['height'] * 0.7)
x = m['x'] + (m['width'] - w) // 2
y = m['y'] + (m['height'] - h) // 2
print(w, h, x, y)
")"
fi

hyprctl --batch "keyword animations:enabled 0 ; dispatch moveworkspacetomonitor special:$SPECIAL $MON_NAME ; dispatch resizewindowpixel exact $W $H,class:^($CLASS)\$ ; dispatch movewindowpixel exact $X $Y,class:^($CLASS)\$"

# --- Batch 2 : tout est en place, on révèle/masque selon l'état VOULU ---
# On revérifie l'état réel juste avant de conclure (l'évacuation a pu le
# changer) et on ne toggle que si nécessaire pour atteindre WANT_VISIBLE.
CURRENT_SPECIAL=$(hyprctl monitors -j | python3 -c "
import json, sys
for m in json.load(sys.stdin):
    if m['name'] == '$MON_NAME':
        print(m['specialWorkspace']['name'])
")
if [ "$CURRENT_SPECIAL" = "special:$SPECIAL" ]; then
    CURRENT_VISIBLE=1
else
    CURRENT_VISIBLE=0
fi

if [ "$CURRENT_VISIBLE" != "$WANT_VISIBLE" ]; then
    hyprctl --batch "keyword animations:enabled 1 ; dispatch togglespecialworkspace $SPECIAL"
else
    hyprctl keyword animations:enabled 1
fi
