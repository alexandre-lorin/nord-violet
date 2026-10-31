# Date and calendar — 19 September 2026

Choice validated by Toubi: **overview B + calendar A**, according to `maquettes/calendrier.html`.

- Time overview: day in large, day of week and month/year in French.
- Right click: compact calendar of 332 × 372 px on the screen used.
- Week starting Monday, attenuated neighboring days, discreet purple selection,
  point under today, month arrows and Today button.
- Escape, outside click or right click again on the time: close.
- Keyboard arrows: day selection; Previous/next page: month;
  Start: today. The selection is used to consult a date, without an external calendar.
- Only one calendar open at a time. From an open calendar, clicking on
  the other screen closes it; the next click opens that of this screen.

## Integration

`CalendarHub.qml`, loaded by the Control Center shell, creates a small area
transparent input interface above each native Waybar clock. The time remains
displayed by Waybar. This surface allows the real flyover B with two columns,
that the native Pango tooltip does not allow you to compose properly.

`CalendarClock.qml` supports hover, right-click and layer-shell surfaces.
`CalendarCard.qml` and `CalendarButton.qml` use the shared colors of
`theme/Theme.qml`. `CalendarMath.js` calculates dates at local noon to avoid
the differences during time changes.

The calendar is anchored before display: no floating window to move
after opening. No extra special space. The exterior closure
uses `HyprlandFocusGrab` on calendar only: include area
of the clock in the capture was causing the second click to be lost without movement.

Both active Waybar files are monitored to track up/down position,
the height, the margins and the presence of the central clock. The spacing between
bar and popup is 12 px. The input area is 66 px wide, suitable for
current format `HH:MM`; review this width if the format or font changes.
The current configuration uses explicitly named outputs in
`config.jsonc`, taken up by the calendar. A shift towards motives of
Waybar output would ask to adapt this correspondence.

Native tooltip is disabled in active file
`~/.config/waybar/modules-common.jsonc`. `opacity.css` has not been modified.
The active Waybar folder remains independent of its old copy in Git.

## Validation

- Six real cycles on HDMI-A-1 and eDP-1: hover, right click, close by
  Escape/right click/outside click. Positions controlled via composer.
- Navigation to the next month and return to today visually verified.
- Controlled switching between screens: only one calendar visible.
- Bar temporarily placed at the top: calendar anchored at y=46, then back
  exact to the original file and layout.
- Nine date tests: leap years, change of year, change
  time, Monday to Sunday grid and keyboard navigation.
- The eight existing flyout placement tests also pass.
- `qmllint` changes to CalendarCard and CalendarButton. On CalendarClock and
  CalendarHub, it exits with code 255 without diagnosis; their actual loading
  and the above interactions have been verified without new QML errors.
- No configuration error Hyprland; `git diff --check` passes.

Commands reproducible from `/home/toubi/dotfiles`:

```sh
TZ=Europe/Paris node --test nord-violet/tests/test_calendar.cjs
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s nord-violet/tests -v
```

Prior backup:
`~/.local/state/nord-violet/backups/20260919-224328-calendar/`.
New Calendar and CalendarMath components are separated from files
existing. To remove the integration, restore `shell.qml`, `qmldir` and
`modules-common.jsonc` from this save, then reload Waybar.
