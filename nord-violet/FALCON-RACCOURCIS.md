# Falcon — quick access and controls

Integration of 21 September 2026, approved by Toubi.

| Shortcut | Action |
|---|---|
| Super+B | Show/hide Falcon on active monitor |
| Super+arrows | Focus between windows |
| Super+Shift+arrows | Move window |
| Super+Ctrl+arrows | Resize in steps of 40 pixels |
| Ctrl+N in Falcon | Add according to section: objective/directive, session or journal |
| Ctrl+P in Falcon | Enter an order |
| Tab / Shift+Tab | Next/previous heading, or form field |
| Escape | Cancel, return to home, then hide the popup |

The bar maintains four surfaces: `m` Plane, `f` Focus/timeline, `j` Journal and
`b` Balance sheet. `t` opens Today, `c` Cycles and `?` helps. They all share
directly the data from Folio.

Super+G remains Work/Game mode; Super+D remains Discord. The eight shortcuts
Hyprland move/resize HJKL become the arrows.

## Launcher

Source: `../hypr/.config/hypr/scripts/falcon-popup.py`, linked to
`~/.config/hypr/scripts/falcon-popup.py`. Dependencies already present: Python 3,
Hyprland, Alacritty and `~/.local/bin/falcon`.

Class `falcon-popup`, special space `nvfalcon`. The rule places the window
silently in this space from its creation, floating and without animation.
The launcher calculates the size in the usable area of the screen, prepares the
position while the space is hidden, waits for Hyprland to confirm the
position and size, then displays and gives focus. It takes into account the
rotation, scale and reserved margins. Maximum size 1400×850;
68 % width and 75 % useful height on small screens.

A lock prevents concurrent calls from creating multiple instances. A reminder
on the other screen moves the same window; hiding preserves the input and the
session. `q` actually closes the process. The environment `FALCON_POPUP=1`
allows Escape to hide the space instead of exit, only in the popup.
The overall animations are not changed.

The active configuration `~/.config/hypr/windowrules.conf` is independent of
its Git copy. The three Falcon rules were added to both files without
replace their other differences. `keybinds.conf` remains a link to Git.

## Verification and rollback

Desktopless testing: `python3 tests/test_falcon_popup.py` from this folder.
They cover geometry, screen switching, placement/display order and refusal
to display an unconfirmed position. The native recipe also checks the
same instance on HDMI-A-1 then eDP-1, quick recalls and Esc.

Backups before change:
`~/.local/state/falcon/backups/raccourcis-formulaires-20260921-200744/`.
They contain the shortcuts, the two rules files and the sources
Previous Falcons. To undo only shortcuts, restore lines
affected from these copies and remove the three Falcon rules, then launch
`hyprctl reload`. Do not blindly overwrite a file that has received others
changes since then.

The first start guide and functional limits are in
README Falcon (local reference, not included in this repository).
