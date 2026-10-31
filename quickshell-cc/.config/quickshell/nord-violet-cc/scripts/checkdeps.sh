#!/usr/bin/env bash
# checkdeps.sh — vérifie tous les binaires externes que nord-violet-cc
# appelle en sous-processus, à travers les 7 pages. Généré par grep sur
# le code QML lui-même (pas une liste tapée à la main), donc censé être
# exhaustif au moment où ce script a été écrit — si tu ajoutes une
# commande dans une page plus tard, pense à l'ajouter ici aussi.
#
# Sortie : une ligne de statut par outil, puis une ligne finale
# "MISSING_PKGS:<paquets arch séparés par des espaces>" (vide si rien ne
# manque). SystemPage.qml parse cette dernière ligne pour construire le
# `paru -S ...` copiable, et affiche tout le reste tel quel.

declare -A PKG_MAP=(
  [hyprctl]=hyprland
  [gsettings]=glib2
  [brightnessctl]=brightnessctl
  [ddcutil]=ddcutil
  [pactl]=libpulse
  [nmcli]=networkmanager
  [bluetoothctl]=bluez-utils
  [makoctl]=mako
  [hyprlock]=hyprlock
  [cpupower]=cpupower
  [nvidia-smi]=nvidia-utils
  [powerprofilesctl]=power-profiles-daemon
  [kvantummanager]=kvantum-qt5
  [wl-copy]=wl-clipboard
)

missing=()

echo "Dépendances de nord-violet-cc :"
echo

for bin in "${!PKG_MAP[@]}"; do
  if command -v "$bin" >/dev/null 2>&1; then
    printf "  ✓ %s\n" "$bin"
  else
    printf "  ✗ %s (manquant — paquet: %s)\n" "$bin" "${PKG_MAP[$bin]}"
    missing+=("${PKG_MAP[$bin]}")
  fi
done

echo
echo "systemctl, uname, uptime, df, cat, which : fournis par le système de base, non vérifiés."
echo
if [ ${#missing[@]} -eq 0 ]; then
  echo "Tout est installé."
else
  echo "${#missing[@]} paquet(s) manquant(s)."
fi

echo "MISSING_PKGS:${missing[*]}"
