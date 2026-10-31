# Nord Violet — harmonization of September 17 2026

Last explicit choice of Toubi: common accent **#9b7cff**.

## Applied state

- Hyprland: active borders and accent of `palette.conf` aligned; alpha
  of `accent_dim` retained. The active session border has been updated.
- Control Center and Waybar: same emphasis, including workspace points.
- Mako: focus of normal notifications aligned; critical red preserved.
- Alacritty: added `alacritty.toml` importing the existing palette; cursor
  purple. The ANSI Nord colors, including magenta `#b48ead`, retain their role.
- GTK 3 and GTK 4: Breeze-Dark, Papirus-Dark, cursor `breeze_cursors` size 24,
  Inter 10. These resources are installed. The corresponding GNOME preferences
  are aligned, with `prefer-dark` and JetBrains Mono 10 for the minivan.
- GTK 4 imports GTK 3 color overload. Old Breeze definitions
  clear files remain on disk but are no longer imported. The Libadwaita accent
  is also defined; the selected funds remain not very opaque.
- Hyprlock: accent aligned and comment corrected. Lock bottom remains
  `halo-wallpaper-4k.jpg`, the desktop one remains `wp1.png`.
- Fuzzel and wlogout: existing accents aligned. No Rofi configuration added.

## Synchronization

`~/.config/quickshell/nord-violet-cc/scripts/accentctl.sh` propagates choice
Settings to existing active files: Hyprland, Hyprlock, Waybar, Mako,
Alacritty slider, GTK, Fuzzel and wlogout. It does not generate full palettes.
The danger, success and ANSI colors remain independent.

Stow and permissions symbolic links are preserved. The script validates the
formats before any writing, reloads Mako and Waybar and updates the border
Hyprland. GTK applications may need to be reopened; Hyprlock
applies its colors to the next lock. Reopen terminals already
launched if they have not loaded the new main file.

Attention: `~/.config/hypr/hyprlock.conf`, `~/.config/waybar/` and
`~/.config/gtk-4.0/` contain repository-independent active files.
Do not overwrite these folders with an old Stow package. Existing copies
of `hyprlock.conf` and `waybar/colors.css` in the repository have been aligned to
this intervention; subsequent emphasis changes target active files.

## Validation

- Isolated tests of the script: propagation, preservation of Stow and alpha links,
  unchanged semantic colors, rejection of invalid arguments and formats.
- `bash -n`: valid accent script and workspace points.
- `qmllint`: no diagnostics on Colors.qml and AppearancePage.qml.
- Quickshell: real reload confirmed by `Configuration Loaded`.
- Hyprland: no configuration error; active border `ff9b7cff`.
- Mako: successful reload.
- GTK 3 and GTK 4: CSS loaded without error by the installed parsers; settings
  effectives read in Gtk.Settings. Libadwaita confirms dark mode.
- Alacritty: Valid TOML, import accepted by `migrate --dry-run --silent`.
- `git diff --check`: succeeded. No commits created.

The full visual recipe for apps and locking remains to be done.
The sandbox reports its dconf cache as read-only; the writings via
GSettings nevertheless succeeded, and the values were read back into GTK.

## Backup and recovery

Backup before intervention:
`/home/toubi/.local/state/nord-violet/backups/20260917-221624/`.

`files.json` indicates the paths, their targets and their existence before intervention.
`gsettings.json` keeps the old values ​​of only modified preferences.
To restore, copy the backed up files to their indicated targets,
by preserving the links; the main Alacritty file was missing before.
Restore the preferences with `gsettings set`, then reload the components.

The original Claude transmission is preserved in the downloads.
Its `CONTEXT.md` and `CHANGELOG.md` go up to v46; sound `HANDOFF.md`
is ancient (v32). Audio patch v43 is missing in all three active files,
and the validations of the Alacritty/Swappy v44–v46 patches remain a work in progress
distinct, not modified during this visual harmonization.
