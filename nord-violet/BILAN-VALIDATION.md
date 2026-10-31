# Review Hyprland — 2 October 2026

## Completed in this pass

Additional aesthetic touch-up: 20 px content margins, navigation
224 px, inter-sections without cumulative margins, more readable titles, description
compact, scroll indicator, advanced rectilinear toggle. General view:
values and controls anchored to the same right edge, without floating columns.
Sound and General View captures rechecked after these adjustments.

- Opening Settings with window activation; separate navigation from
  the opening. Do not call `show()`/`showNormal()` on every change
  of page: this alternated the size between normal and enlarged.
- Navigation Sound → Screens → Funds → Desktop checked: a single window,
  1180 × 760 on all four pages, after correction.
- Sound: actual list of outputs/inputs, volume/mute, common playback,
  audio events, write consolidation, and backup replay.
- Screens: compact minivan header, existing frequencies retained,
  real internal brightness with periodic rereading (1,5 s).
- Office: removal of the hero serif and the decorative thumbnail,
  MPV states and vertical sections.
- Funds: gallery preserved, straighter monospace surfaces/buttons;
  No-action future options removed from the interface.
- CC: observed size 620 × 320; Opens General view; Firm escape
  the panel if no selector is open. Grouped volume entries,
  reread after write and output change events tracked.
- `clock` available in ~/.local/bin: calls exactly `chrono clock`.
  Vertical presentation unchanged, no modification of chrono.py.

## Verified

- Local Sound, Screen, Background and Desktop captures inspected.
- Audio data read: four outputs, three microphones, readable names.
- Brightness read on `nvidia_0`; OSD brightness triggered without changing
  hardware (display test only).
- CC: S and Escape shortcuts exercised in real session.
- A single instance Quickshell after shutdown then clean startup.
- QML of affected files validated; 27 Python tests and 9 tests schedule.
- `clock --help` and launcher syntax validated.

## To be validated with Toubi

- Aesthetics and density of the four pages compared to model A.
- Quickly drag the audio/mic/brightness sliders, then edit
  from Waybar/pavucontrol and observe the menus: the mechanisms are
  present, but no real volume/mute change has been imposed
  during this pass. Do not confuse reading data and testing
  complete round trip of all controls.
- Output/mic selection, import/background application and change
  frequency: commands retained, not exercised on the desktop.
- Focus, profiles, Wi-Fi and DND: no real toggle during review.

## Staying out of this pass

- October 3 pass: Profiles, Omni, Notifications, Connections,
  Shortcuts, System and Hyprland harmonized (8 px spacing,
  reduced headers, removal of serif titles, straight outlines).
  Seven pages opened at 1180×760 and catches inspected; description
  non-truncated profiles and abbreviated version Hyprland after review.
  User aesthetic validation and testing of real actions remain
  necessary; no Wi-Fi toggle or profile change imposed.
- Battery discharge after switching off: cause not established, compare one
  direct shutdown from the terminal to the menu without modifying the BIOS.
- Check `[Long_Life]` after a reboot: prepared service and mode
  reactivated by Toubi; persistence after restart to be confirmed.
- The Qt crash linked to old Shortcuts has a keyboard bypass, not
  an internal Qt fix.

Nothing Link voluntarily remains outside the scope.
