# RK R98Pro and integrated keyboard — 6 octobre 2026

RK devices recognized by Hyprland: `rk-r98pro` and `rk-r98pro-keyboard`. Main integrated keyboard: `at-translated-set-2-keyboard` ; some laptop commands also go through ITE / video-bus.

## Orders

Physical capture of 7 October: Fn+F5 from RK issues XF86Tools (keycode 179), F5 alone emits F5 (keycode 71). Binding XF86Tools added only for RK devices. spotify-focus.py launches Spotify if necessary then displays its existing window (desktop 15), without modifying F5 alone. 50 Python tests pass; real focus Spotify checked. Old media mappings remain compatible variants, not proof of the signal of this model.

- RK wheel and `Fn+F11/F12`: volume −/+ by 1%, capped at 100%, direct wpctl command to preserve fluidity. Waybar and audio menu follow their existing timing mechanism; no separate OSD at each RK audio notch.
- Wheel click / `Fn+F10`: mute, audio control and existing OSD.
- `Ctrl` + wheel (or `Ctrl+Fn+F11/F12`): brightness of the screen focused by 5 points. Integrated display via brightnessctl, external via DDC/CI. No silent fallback to the integrated screen if the external one is not accessible.
- `Fn+F7/F8/F9`: previous / play-pause / next via playerctl; `Fn+F6`: stop. Requires MPRIS compatible app.
- Native volume/brightness keys of the laptop: previous behavior unchanged (5 %).
- `Fn+F1`: Yazi; `Fn+F2`: Firefox; `Fn+F3`: mail manager configured (currently Firefox, no dedicated mail client installed); `Fn+F4`: qalc calculator in terminal; `Fn+F5`: Spotify. Only F1..F12 remains available for applications.
- Brightness retouch: popup removed; DDC bus cache during 30 seconds, worker preserved 700 ms between screens and DDC writing without systematic automatic rereading (`--noverify`). Standard DDC hardware deadlines preserved. Real fluidity to be revalidate by Toubi.

Audio events from the wheel and Fn keys are processed identically when they have the same keysym. The mappings target the entire RK, not exclusively the wheel.

## Implementation and validation

### Laptop Lenovo LOQ 15ARP9

Actual capture of 8 octobre : Fn+F9 → XF86Favorites (372), Fn+F10 → XF86TouchpadOff (540), Fn+F11 → Ctrl+Alt+Tab (Control_L then Alt_L then Tab). Mapping: F9 opens Omni; TouchpadOff deactivates ELAN, TouchpadOn reactivates it (intended counterpart, On event not yet captured); F11 opens Omni Windows. No diversion of F9/F10/F11 alone or the RK. Order Hyprland device[elan06fa:00-04f3:327e-touchpad]:enabled true tested successfully. F8 remains awaiting verification; the following speculative notes are historical.

Correction Alt+Tab: in v0.56.2 the legacy translator of `cyclenext` ignores the argument `all` (checked in DispatcherTranslator.cpp). Bindings now use `window-cycle.py`, which cycles through normal desktop windows on all screens and excludes hidden, unmapped windows, scratchpads, and Nord Violet surfaces. Alt+Shift+Tab reverses the path. Stable order of client list, no MRU or Windows preview. Actual window change verified then initial focus restored; 47 tests pass. The laptop's applications key is connected to Omni Windows via Super+Tab / XF86TaskPane, to be confirmed physically. The cyclenext notes below are historical.

Additional keys configured separately: XF86AudioMicMute → default mic (wpctl), XF86Calculator → qalc, F1–F3 and F5–F6 use the audio/brightness controls already present. Alt+Tab and Alt+Shift+Tab added globally: cyclenext in the current desktop, without selection interface or Windows MRU order; Super+W retains the Omni Windows palette.

According to [Lenovo](https://download.lenovo.com/pccbbs/pubs/loq_15_16/html_en/EN/ref_hotkey_icons.html), the S star is Lenovo Smart Key, the screen selector adjusts the displays, and F11 with rectangles represents the display of applications in thumbnails (not necessarily Alt+Tab). F8 airplane mode, F9 Smart Key, F10 touchpad and the exact F11 event remain to be captured physically before remaping them. Do not add a second rfkill toggle without checking the kernel one. Do not present these keys as already validated.

Existing Hyprlang configuration retained. The source of Hyprland **v0.56.2**, `src/config/legacy/ConfigManager.cpp`, confirms the flag `k`: list of devices after the key, names separated by spaces; prefix `!` for exclusion. No Lua migration.

`active-brightness.py` chooses the focused connector on each invocation, redetects the DDC bus per connector, and groups concurrent notches with two locks in XDG_RUNTIME_DIR. Initial hardware read, bounded calculation, then a batch write. Minimum internal 1%, external 0%. Hardware errors give a notification, without changing another screen.

44 Python tests pass, including selection of the active screen, limits and conservation of concurrent screens. `hyprctl configerrors` empty after reloading. Actual hardware detection: HDMI-A-1 on i2c-4; integrated display eDP-1 excluded from DDC. To validate with Toubi: turn the wheel alone, click, then turn with Ctrl; check that Ctrl does not also change the sound, and check the laptop keys. i2c-dev persistence after reboot remains separate.

Sources: [notice R98Pro](https://manuals.plus/m/74d361820f508dd0536c05f122a908724e0ee49a5b8e21c0c4cfafa5ba269888_optim.pdf), [parser Hyprland v0.56.2](https://github.com/hyprwm/Hyprland/blob/v0.56.2/src/config/legacy/ConfigManager.cpp).
