# Volume wheel — 6 October 2026

## Final state: Waybar native control restored

After further return of jerks, `custom/audio` is replaced by native `pulseaudio` in both configurations. `scroll-step: 1`, `max-volume: 100`, no commands `on-scroll-up/down`: No Python/wpctl launch or additional JSON stream during scroll. Left click mute, flyout wheel click, pavucontrol right click retained. Capture after reload: 53% in Waybar, 53% on default output, unmuted. One bar per screen. The `waybar-watch` script remains available but is no longer used by Waybar. The feeling must be validated by the user.

Retouching after reporting blockages: Waybar flow grouped in bursts (maximum one reading per 35 ms, last update kept). Control center and general view of settings: polling stopped when closed; sink-input notifications with no effect on overall volume ignored; grouped and non-competing flyout audio playbacks. 36 Python tests passed, QML validation and real shell reload passed. No memory saturation observed; the overall lag was not reproduced and cannot be declared fully resolved without user feedback.

The first fix capped the volume with three successive pactl calls under lock. It caused a queue when fast scrolling; Waybar displayed the status with an interval of one second.

The variation now uses a single call `wpctl set-volume --limit 1.0 @DEFAULT_AUDIO_SINK@ 1%+` (or `1%-`). The same limited controls are also used for the volume keys via the common audio script.

Waybar uses `audio-devices.py waybar-watch`, a JSON feed powered by `pactl subscribe`, with no 1-second polling. Update on release events and server change; identical states filtered; subscriber process stopped on exit. `restart-interval: 1` allows Waybar to restart the flow if the subscription is cut.

Validation: 34 Python tests passed, JSON output of the stream controlled on the real audio server, volume and mute preserved (zero variation test), one Waybar surface per screen after reload. No sound testing or manual scrolling done for the user.
