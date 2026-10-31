# Nord Violet

A dark Hyprland desktop configuration for Arch Linux, organized as GNU Stow packages. It combines Waybar, a Quickshell control center, launcher and notification styling, and desktop utilities.

## Repository layout

- `hypr/`: Hyprland configuration, key bindings and helper scripts.
- `quickshell-cc/`: the Nord Violet control center and its components.
- `waybar/`, `mako/`, `fuzzel/` and `alacritty/`: application configuration.
- `nord-violet/`: integration notes, tests and additional desktop components.
- `thunar/` and `yazi/`: file-manager configuration.

## Installation

This is a snapshot of a particular desktop setup, not a universal installer. Review paths, monitor settings, hardware-specific options and commands before applying it. Back up your current configuration first.

```sh
sudo pacman -S stow git
git clone https://github.com/alexandre-lorin/nord-violet.git ~/dotfiles
cd ~/dotfiles
stow --simulate --verbose --target="$HOME" hypr waybar mako alacritty
```

The last command is a dry run. After reviewing its output, remove `--simulate` to apply the selected packages. Stow may refuse conflicting files; preserve or move your existing configuration instead of deleting it blindly. Other components need their own dependencies and setup.

## Documentation

- [Design and integration](nord-violet/HARMONISATION.md)
- [Audio and session controls](nord-violet/AUDIO-WLOGOUT.md)
- [Calendar](nord-violet/CALENDRIER.md)
- [Bluetooth](nord-violet/BLUETOOTH.md)
- [Calculator](nord-violet/CALCULATRICE.md)
- [Validation record](nord-violet/BILAN-VALIDATION.md)

Validation notes describe the original machine and the date of each check. They do not certify every component on another system. Some application labels remain in French.
