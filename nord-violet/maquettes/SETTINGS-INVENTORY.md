# Nord Violet — settings inventory

Design inventory for future application of settings. He compares
Nord Violet with Ryoku Settings, Caelestia Nexus, Noctalia SettingsPanel and
DankMaterialShell. An entry listed here is a product possibility, not
confirmation that it is already implemented.

References inspected:

-<https://github.com/Ryoku-dev/ryoku>
-<https://github.com/caelestia-dots/shell>
-<https://github.com/NotWinder/noctalia-shell>
-<https://github.com/AvengeMedia/DankMaterialShell>

## Recommended structure

### Home

- global state of the session and the shell;
- CPU, memory, temperature, battery and storage;
- updates available;
- active energy profile;
- shortcuts to the last modified settings;
- rapid diagnosis of the configuration;
- import, export and restore settings.

### Appearance

- dark, light or automatic theme;
- fixed accent or extracted from the wallpaper;
- palette variants: tonal, expressive, faithful, neutral, monochrome;
- surface colors, texts, borders and states;
- contrast intensity;
- transparency and opacity;
- blur, noise, saturation and shadows;
- overall radius of the angles;
- thickness and color of the borders;
- interface font, monospace font and weight;
- global scale of the interface;
- compact, normal or comfortable density;
- theme of icons and cursor;
- live preview before application;
- propagation to Waybar, terminal, GTK, Qt, notifications and screen
  locking.

### Wallpapers

- local library with miniatures;
- search, favorites and categories;
- import a file or folder;
- temporary preview before validation;
- random background;
- slideshow at startup, periodic or daily;
- selection from favorites or a category;
- rotation interval;
- transitions: fade, slide, grow or random;
- adjustment: fill, adapt, center or stretch;
- darkening of the background under the widgets;
- animated or video backgrounds, optional;
- same background on all screens or background per screen;
- synchronization with the lock screen;
- automatic pallet extraction;
- light/dark choice and colorimetric variant derived from the image;
- “next background” shortcut and launcher integration.

### Desk and bar

- position, size, margins and screen of the bar;
- persistent bar or smart hiding;
- transparency, rounds and Wayland layer;
- composition by left, center and right zones;
- order of modules by drag and drop;
- workspaces, active window, open applications, media, clock,
  weather, battery, network, Bluetooth, audio, keyboard, system monitors,
  updates and tray;
- options specific to each module;
- date and time formats;
- number and appearance of workspaces;
- application indicators and window icons;
- dock: position, size, zoom, hiding and pinned applications;
- desktop widgets: clock, weather, calendar, viewer and notes;
- position and visibility of widgets per screen;
- behavior of Control Center, OSD and notifications.

### Animations

- global activation and reduction of movements;
- fluid, precise or kinematic profile;
- overall speed;
- opening, closing and moving windows;
- change of workspace;
- morphic panels, drawers and popups;
- advanced curves and springs;
- animated blur and distortion, with performance mode;
- preview of each animation.

### Screens

- graphic representation and movement of monitors;
- activation and main screen;
- resolution, frequency, scale and rotation;
- duplication or extension;
- position and transformation;
- VRR, HDR and color depth if available;
- integrated brightness and DDC;
- gamma and color temperature;
- night light and programming;
- saved multi-screen profile;
- bar, widgets and wallpaper configurable per monitor.

### Sound

- default output device;
- volume, mute and maximum amplification;
- profiles and output ports;
- input device, gain and mute;
- noise reduction;
- volumes per application;
- favorite media player;
- no volume keys;
- Audio OSD;
- optional interface sounds.

### Connections

- Wi-Fi activation and list of networks;
- connection, forgetting and modification of a network;
- hidden network;
- Ethernet status;
- access point;
- VPN: addition, connection and deletion;
- Bluetooth activation;
- discovery, association and forgetting of devices;
- battery level of compatible devices;
- airplane mode.

### Entries

- layout, variant and model of the keyboard;
- several layouts and toggles;
- repetition delay and speed;
- common remappings;
- mouse sensitivity and acceleration;
- natural scrolling;
- touchpad speed and profile;
- tap-to-click, secondary click and mute while typing;
- multi-finger gestures;
- cursor theme, size, hiding and effects.

### Shortcuts

- complete list from the active configuration;
- search by action or combination;
- modification and deletion;
- adding custom commands;
- categories: applications, windows, spaces, system and capture;
- conflict detection;
- return to default values;
- visual aid openable by shortcut.

### Energy and session

- performance, balanced or economy profile;
- battery status and health;
- Lenovo conservation mode and thresholds actually supported;
- different behavior on mains and battery;
- darkening delay, locking, switching off and suspension;
- behavior when closing the hood;
- sleep inhibitor;
- suspension during playback or recording;
- locking and authentication;
- avatar, clock, notifications and media on the locked screen;
- session menu and confirmations.

### Applications and services

- default applications: terminal, browser, files, editor and media;
- applications at startup;
- user services and systemd state;
- notifications: position, duration, grouping and rules by application;
- clipboard and history;
- screenshot and video recording;
- quality, codec, FPS, audio and output folder;
- OCR, QR code and color selection;
- weather, city and units;
- language, region, formats and time zone;
- printers and user accounts, to be considered only if reliable.

### Hyprland advanced

- Dwindle or Master layout;
- gaps, borders, rounds, shadows, blur and opacity;
- floating, pinned and pseudo-tiling windows;
- window rules and layer rules;
- special spaces;
- plugins Hyprland;
- session environment variables;
- start commands;
- configuration by application;
- reloading with validation and backtracking;
- display of the actually active value.

### Maintenance and extensions

- shell version and components;
- updates with release notes;
- diagnosis of dependencies;
- recent logs and errors;
- backup, export and import;
- reset by section;
- additional plugins and widgets;
- compatibility check;
- information and credits.

## Priorities for Nord Violet

### V1 — necessary

- Appearance and live preview;
- Wallpapers and dynamic palette;
- Desk and bar;
- Screens;
- Her ;
- Connections;
- Entries;
- Shortcuts;
- Energy ;
- explicit backup, undo and restore.

### V2 — important

- detailed animations;
- lock screen;
- notifications and OSD;
- default applications and autostart;
- rules Hyprland;
- multi-screen profiles;
- global search with synonyms.

### V3 — optional

- third-party extensions and widgets;
- video funds;
- shareable profiles;
- printers and users;
- complete editor of environment variables.

## UX guardrails

- the Control Center remains reserved for immediate actions;
- Settings do not launch any privileged command without explanation;
- options not supported by the machine are not simulated;
- any risky modification has validation and rollback;
- Advanced mode hides complexity without hiding common functions;
- each search directly opens the setting found;
- no decorative adjustment must be presented as functional.
