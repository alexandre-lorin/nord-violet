# Sound and wlogout — finalization of September 20 2026

## Sound Panel

The audio panel displays the calendar presentation: width of 332 px,
`Theme.surface` background, neutral border, 18 px radius, Inter font and margins
20 px. Purple marks the volume and the selected output. The outer border
Hyprland is disabled only for this panel, whose outline QML draws.

Each output has a short name and a context line:

| Exit | Subtext |
| --- | --- |
| MFG27F4Q screen | HDMI/DisplayPort |
| Elgato Wave:3 | Headphone return · USB |
| Laptop Speakers | Integrated audio |
| HyperX Cloud III | Headset · USB |

`scripts/audio-devices.py` produces these labels from the properties of the
devices. The scripts `audiosink.sh` and `audiosinks.sh` also use it:
the names are therefore shared with the Control Center and its settings. The names
PipeWire internals are not modified and remain the targets of the commands.

The panel displays the mute state separately from the stored volume and offers a
button to mute/unmute the sound. The cursor works with the mouse,
wheel and keyboard. External changes are replayed every second
during display. The list is only rebuilt if its data changes.

The v47 placement mechanism is retained: size calculated explicitly,
position confirmed before revelation, without movement animation. With the
four current outputs, the panel measures 332 × 464 px. Beyond the height
maximum, the list scrolls.

The selection continues to change the default output, as before.
This work does not force the migration of flows already explicitly directed to
another device.

On September 23, this policy was centralized in `audio-devices.py`:
the popup, Control Center, Audio page, Waybar, multimedia keys and
The OSD all explicitly resolve PipeWire output by default. Actions
volume and mute no longer each choose their target separately.

In Waybar, left click now opens the audio panel, wheel click
mutes or unmutes and right-click keeps `pavucontrol`. The files
assets `modules-common.jsonc`, `flyout-trigger.sh` and `osd-trigger.sh` are
now copied identically into the repository.

## Wlogout

**Ctrl + Esc** opens the clean editorial variant A on the active screen:
time and date on the left, five actions on the right. The composition is displayed at
1,5 times the initial size. The shortcuts L, U, E, R and S occupy a column
separate side. Esc reminder is no longer displayed, but Esc still closes
the menu.

The background is matte black and the purple accent remains reserved for the focus and the key
active. There is no icon or glow. The composition of 23 September uses a
central editorial panel: assertive clock on the left, vertical separation and
actions on the right. The first action is selected upon opening, with a
Fine purple mark and discreet framing. Disconnect, restart and
extinction require confirmation; locking and standby remain direct.
In a confirmation, Enter overrides default and Tab or side arrows
select confirmation.

The menu is now a dedicated Quickshell surface. `launch.py` chooses the
output Hyprland active, reads the current accent and transmits the five commands of the
existing layout without modifying them. On a narrow screen, the composition is placed
vertically. Preview mode replaces all system commands with `true`.

To review the rendering without triggering a system action:

```sh
python3 ~/.config/wlogout/launch.py --preview
```

This mode uses the actual Quickshell component and overrides all five commands.

## Validation

- 25 Python tests passed: nine name/state/audio command tests, four
  session menu, four Falcon tests and eight flyout placement tests.
- Five audio cycles on HDMI-A-1 and eDP-1: correct final position every time
  first visible sample, without return from the jump to the opening.
- Five additional Wi-Fi cycles: correct end positions; the size
  can always evolve with the scan results, pre-existing behavior.
- Real audio interactions: mute without changing the stored volume,
  volume adjustment using the keyboard, selection of the current output. Raw values
  channels and mute state restored after testing.
- The editorial menu has been visually verified to scale 1,5 on HDMI-A-1 and
  eDP-1. The five shortcuts, cancellation and confirmation have been exercised
  with the actions neutralized. No disconnection, standby, shutdown or
  No restart operation was performed for these tests.
- `qmllint` on AudioFlyout, Bash wrapper syntax, Hyprland configuration
  and `git diff --check` pass.
- On September 20, the new Control Center process loads the
  configuration. It reports a portal registration warning
  office; no QML loading errors are reported.

From `/home/toubi/dotfiles`:

```sh
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s nord-violet/tests -v
qmllint -I /usr/lib/qt6/qml quickshell-cc/.config/quickshell/nord-violet-cc/AudioFlyout.qml
```

Prior backup:
`~/.local/state/nord-violet/backups/20260919-230411-audio-wlogout/`.
Captures and measurements: `~/.local/state/nord-violet/audio-wlogout-20260919/`.
Editorial recipe: `~/.local/state/nord-violet/wlogout-editorial-20260921/`.
Backup before integration:
`~/.local/state/nord-violet/backups/wlogout-editorial-20260921-225452/`.
No commits created.
