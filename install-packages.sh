#!/usr/bin/env bash
# Installation des paquets — Nord Violet rice sous Hyprland
# Vérifie chaque bloc avant de lancer, certains paquets peuvent déjà être là.

set -e

# --- Compositeur + portail ---
sudo pacman -S --needed \
  hyprland \
  xdg-desktop-portal-hyprland \
  qt5-wayland qt6-wayland

# --- Barre, launcher, notifs ---
sudo pacman -S --needed \
  waybar \
  rofi-wayland \
  mako

# --- Idle / lock officiels Hyprland (pas swayidle/swaylock) ---
sudo pacman -S --needed \
  hypridle \
  hyprlock

# --- Screenshot + clipboard ---
sudo pacman -S --needed \
  grim slurp swappy \
  cliphist wl-clipboard

# --- Permissions, audio, réseau, luminosité ---
sudo pacman -S --needed \
  polkit-gnome \
  pipewire wireplumber pipewire-pulse \
  brightnessctl \
  network-manager-applet

# --- Terminal ---
sudo pacman -S --needed alacritty

# --- Polices : nerd font pour les icônes Waybar (remplace tes SVG inline) ---
sudo pacman -S --needed ttf-jetbrains-mono-nerd

# --- Outils dotfiles ---
sudo pacman -S --needed stow git

echo "Terminé. Reboot ou relance la session avant de tester Hyprland."
