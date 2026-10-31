#!/usr/bin/env bash
# ~/.config/waybar/workspaces-dots.sh
#
# Appelé par le module "custom/workspaces-<sortie>" dans config.jsonc,
# un par écran, avec le nom de sortie Hyprland en argument (ex:
# HDMI-A-1, eDP-1). Affiche un point par workspace assigné à CETTE
# sortie précise, rempli si c'est le workspace actuellement affiché SUR
# CETTE sortie.
#
# Pourquoi ce script plutôt que le module natif hyprland/workspaces :
# retour utilisateur confirmé (captures d'écran) — la classe "active"
# du module natif ne suit que le workspace globalement focus (où est
# la souris/le clavier), jamais par moniteur. Limitation connue,
# reconnue par l'équipe Hyprland elle-même (hyprwm/Hyprland#916), pas
# un réglage caché côté waybar.
#
# Assignation workspace -> moniteur lue dynamiquement via
# `hyprctl workspacerules -j` (règles définies dans hyprland.conf) —
# pas de plage codée en dur ici, donc pas besoin de retoucher ce script
# si tu changes l'assignation plus tard.
#
# Limitation connue (acceptée, pas un oubli) : contrairement au module
# natif, les points ne sont pas cliquables individuellement pour
# changer de workspace — un module custom Waybar est un bloc de texte,
# pas des boutons séparés. Dis-moi si tu veux ce comportement, ça
# demande un widget nettement plus complexe (probablement une popup
# menu Waybar, ou revenir à eww/ags pour ce module précis).
#
# Le markup Pango reprend l'accent de colors.css à chaque exécution.

set -euo pipefail

MON="${1:?usage: workspaces-dots.sh <monitor-name>}"
ACCENT="#9b7cff"
COLORS="${XDG_CONFIG_HOME:-$HOME/.config}/waybar/colors.css"
if [ -r "$COLORS" ]; then
    VALUE=$(sed -nE 's/^@define-color accent (#[0-9a-fA-F]{6});.*$/\1/p' "$COLORS")
    if [[ "$VALUE" =~ ^#[0-9a-fA-F]{6}$ ]]; then
        ACCENT="$VALUE"
    fi
fi

mapfile -t WS_IDS < <(hyprctl workspacerules -j 2>/dev/null | jq -r --arg m "$MON" '.[] | select(.monitor == $m) | .workspaceString' | sort -n)

ACTIVE=$(hyprctl monitors -j 2>/dev/null | jq -r --arg m "$MON" '.[] | select(.name == $m) | .activeWorkspace.id // empty')

if [ "${#WS_IDS[@]}" -eq 0 ]; then
    # Rien trouvé dans workspacerules (aucune règle explicite pour ce
    # moniteur, ou hyprctl indisponible) — plutôt qu'un module vide et
    # silencieux, retombe sur le seul workspace actif connu, si dispo.
    if [ -n "$ACTIVE" ]; then
        WS_IDS=("$ACTIVE")
    fi
fi

TEXT=""
for id in "${WS_IDS[@]}"; do
    if [ "$id" = "$ACTIVE" ]; then
        TEXT+="<span foreground='${ACCENT}'>●</span> "
    else
        TEXT+="○ "
    fi
done
TEXT="${TEXT% }"

jq -nc --arg text "$TEXT" '{text: $text}'
