# Complete audit of the four reference shells

Audit of September 25 2026, carried out from imported local sources. The
Associated generated inventories contain pages, settings, services and
modules found in the code. This document distinguishes the visible functions,
technical drivers and ideas relevant to Nord Violet.

## Audited deposits

| Project | Audited review | Real nature | Raw inventory |
| --- | --- | --- | --- |
| Ryoku | `06091d4` | full Arch distribution, QML hub and shell, Go backends | [RYOKU-INVENTORY.md](generated/RYOKU-INVENTORY.md) |
| Caelestia Shell | `20e625d` | shell Quickshell/QML with C++ and Nexus plugin | [CAELESTIA-INVENTORY.md](generated/CAELESTIA-INVENTORY.md) |
| Noctalia v5 | `f0339ef` | native Wayland shell C++/OpenGL ES | [NOCTALIA-INVENTORY.md](generated/NOCTALIA-INVENTORY.md) |
| DankMaterialShell | `65dbb9f` | QML shell, Go backend and catalog of 786 entries | [DMS-INVENTORY.md](generated/DMS-INVENTORY.md) |

The old `NotWinder/noctalia-shell` was kept locally as a version
legacy. It is not used in the comparison: the current Noctalia is a
native rewriting and its scope has grown significantly.

## Quick verdict

| Need | Best reference | Why |
| --- | --- | --- |
| Artistic direction and movement | Caelestia | morphing surfaces, transitions, strong visual hierarchy |
| Advanced settings of Hyprland | Ryoku | draft, preview, research, composer abilities |
| Coherent shell and modern architecture | Noctalia v5 | unified surfaces, services, configuration and IPC |
| Maximum functional coverage | DMS | system tweaks, plugins, widgets and specialized hardware |
| Backgrounds, colors and app themes | Noctalia + DMS | palettes, models, automation and external targets |
| Configurable bar and widgets | DMS | composition, instances and options per widget |

## 1. Ryoku

### Shell and surfaces

- modular bar with rails, zones, panels, menus, media and HUD
  recording;
- dock with applications, media, menus, pins and hiding;
- desktop with widgets, calendar, weather, statistics, music, lyrics,
  viewer and context menus;
- launcher, notifications, lock, area capture, camera and display
  strikes;
- welcome screen, shortcut help, content pin and tools
  capture;
- Hyprland and Niri support, composer switching and abstraction
  available capacities.

### Settings hub

- Profile: hardware, status, statistics and identity of the machine;
- General: language, region, formats, time zone, weather, font and scale;
- Updates: channel, version, verification and application;
- Screens: detection, layout, resolution, frequency, scale, rotation and
  profiles;
- Connections: Wi-Fi, Bluetooth and hotspot;
- Inputs: keyboard layouts, second layout, XKB options, remaps, mouse,
  touchpad, acceleration, scrolling, gestures and cursor;
- Graphics and energy: AMD/NVIDIA GPU, hybrid modes, VM passthrough,
  CPU settings, profiles, thermals and load limits;
- Animations: activation, speed, curves and categories;
- Lockscreen: appearance, behavior, security and themes;
- Window Manager: layout, gaps, resizing, snapping, borders,
  rounding, opacity, blur, shadows and window behavior;
- Plugins: catalog Hyprland, installation, version, compatibility and options
  dedicated;
- layer rules, window rules and overrides per application;
- Bar Studio: areas, order, widgets, style, dock and preview;
- Desktop: background, brand, viewer and placement;
- Widgets: catalog, addition, placement and settings;
- Launcher: presentation, search and content;
- Shortcuts: inventory, editing, conflicts and actions;
- Session: autostart, commands and environment variables;
- Recording and capture: codec, frequency, audio and destinations;
- Dictation: voice engine, model and microphone;
- Performance: profiles, effect reduction and optimization;
- Fastfetch, configuration import, add-ons, store and Rashin AI assistant.

### Auxiliary engines

- Ryogami: local funds, Wallhaven, Wallpaper Engine/Steam Workshop,
  playlists, post-processing, lighting, Matugen and optimization;
- Palette Bridge: propagation to applications and extensions;
- Ryostore: extensions and widgets;
- CLI, ISO installer, Arch packages, system profiles and systemd services;
- OpenRGB, QMK, lighting, GPU, clipboard, import/undo and publish
  rice via Go backends.

### What to take back

- global search with synonyms and direct links;
- simple/advanced mode;
- draft, diff preview, apply and factory values;
- hiding options that are impossible depending on the hardware or composer;
- Future Bar Studio.

## 2. Caelestia Shell

### Shell and surfaces

- animated background, desktop clock, audio visualizer and background image;
- bar with workspaces, active window, clock, status, tray, power and
  contextual popouts;
- dashboard with media, lyrics, weather, CPU/GPU/RAM/disk performance and
  shortcuts;
- launcher with applications, actions, calculator and search;
- drawers, sidebar, utilities, toasts, notifications, OSD, session and lock;
- zone selector and window information.

### Nexus

- Background and style: library, categories, preview, light/dark mode, palette
  and variants Material;
- Applications: all applications and information sheet;
- Audio: output, input, mute and volume per application;
- Bluetooth: activation, scan, association, connection and device profile;
- Network: list, password, saved networks, manual addition, Ethernet and
  VPN addition;
- Language and region;
- Panels: dashboard, launcher, sidebar, bar/taskbar and utilities;
- detailed bar options: workspaces, clock, tray, active window and
  status icons;
- Services: notifications and background behaviors;
- About and system information.

### Services and engines

- PipeWire audio, brightness, dynamic colors, game mode, idle inhibition,
  nmcli network, notifications, MPRIS, recording, screens, VPN, funds,
  weather and weather;
- native collectors for CPU, GPU, memory, disks, network, sensors, Cava,
  beat tracking and lyrics;
- Hyprland introspection, application data, image cache and image analysis
  colors;
- structured global configuration: general, appearance, background, bar,
  dashboard, launcher, lock, Nexus, notifications, OSD, services, session,
  sidebar and utilities.

### What to take back

- visual language of surfaces and transitions;
- Funds page as central experience, not as form;
- contextual popouts and clear separation between daily uses and settings;
- concise and visual dashboard.

## 3. Noctalia v5

### Shell and surfaces

- multi-screen bars, dock, launcher, overview, window switcher, panel
  sessions and hot corners;
- Control Center, clipboard with images and favorites, notifications with
  history, OSD and tray;
- wallpaper, background panel, backdrop, desktop widgets and editor
  placement;
- lockscreen, setup wizard, polkit, user profiles and separate greeter;
- screen capture/annotation and privacy indicators.

### Bar and widgets

- workspaces, taskbar, active window, launcher, Control Center and settings;
- clock, weather, media, audio visualizer, tray and custom text;
- network, Bluetooth, volume, brightness, battery, energy profile and
  nightlight;
- clipboard, notifications, caffeine, keyboard lock, keyboard layout,
  privacy, capture and theme switching;
- custom buttons, scripts and spacers;
- left/center/right placement, floating behavior, focused screens and
  Configurable click/wheel actions.

### Themes and backgrounds

- integrated, community or background-generated themes;
- light, dark and auto modes, pure black OLED option;
- templates with application and cancellation hooks;
- official templates for Alacritty, Btop, Cava, Emacs, Foot, Ghostty, GTK,
  Helix, KDE, Kitty, Qt, Starship, WezTerm and several composers;
- backgrounds by light/dark folders, fill modes, fill colors,
  multiple transitions, randomization and periodic change;
- blurred/tinted backdrop and linked or independent lockscreen.

### System services

- audio, battery, brightness, Bluetooth, network via NetworkManager/iwd/
  wpa_supplicant, modem, MPRIS, power-profiles, UPower and logind;
- weather, location, vdir calendar, night light and idle;
- DBus, tray StatusNotifier, PAM, polkit and account notifications;
- monitor CPU, frequency, load, temperature, GPU/VRAM, RAM, network, disk and
  swap;
- Hyprland, Niri, Sway, Scroll, Labwc, Mango, KDE, dwl, Triad and integrations
  Umbriel;
- TOML hot-reload configuration, GUI overrides, validation, migrations,
  export, IPC and automation hooks;
- plugins for bar widgets, launcher providers, panels, widgets
  office, orders and services.

### What to take back

- unified architecture and clear shell boundaries;
- provider launcher, directly including emoji;
- reversible application themes;
- parameters in readable file with hot reload and IPC;
- plugins only after kernel stabilization.

## 4. DankMaterialShell

### Main surfaces

- DankBar, Dock, DankDash, DankIsland and app drawer;
- Extensible Control Center, detailed network and process list;
- notifications, history center, OSD, power menu and lock;
- desktop, widgets, workspace overlays, notepad and color picker;
- greeter greetd and complete settings panel.

### Personalization

- palette source, Matugen extraction, colors, surfaces, contrasts,
  transparency, rays, borders and backgrounds;
- programmed light/dark mode;
- typography, sizes, weight, animations, duration, movement reduction,
  shadows and sounds;
- local background, fill, blur, tint, extracted colors, automatic rotation,
  folder, order and interval;
- propagation of the theme to Alacritty, Foot, Ghostty, Kitty, WezTerm, GTK,
  Qt, KColorScheme, Firefox/Zen, Vencord/Vesktop/Equibop, Neovim, Emacs,
  Fcitx5, Hyprland, Niri, MangoWC and others.

### Bar, dock and widgets

- several bars and docks, choice of screen, position, dimensions, floating,
  margins, visibility and autohide;
- composition and reorganization of zones;
- options specific to launcher, workspaces, active window, applications,
  music, clock, battery, system monitor, keyboard, privacy,
  Control Center, tray and updates;
- integrated desktop widgets: clock and system monitor;
- widget instances, placement, text style, background and intensity;
- plugins adding widgets, dashboard cards, pages, providers launcher,
  attached panels and daemons.

### System settings

- graphic display with monitor layout, resolution, frequency,
  scale, rotation, mirror, ICC and identification;
- audio, output/input and applications;
- Wi-Fi, Ethernet, VPN, cellular and network status;
-Bluetooth;
- battery, charge thresholds, profiles, standby and hood actions;
- mouse, touchpad, keyboard, layout and gamma/night mode;
- CUPS printers;
- accounts, user creation and avatars;
- default apps, autostart, open apps and rules
  windows;
- shortcuts, composer configuration and appearance of workspaces;
- notifications, rules by application, DND and sounds;
- lockscreen, greeter, media, weather, location, local and time zone;
- clipboard, palette injection, system updates and plugin management.

### What to take back

- indexed settings catalog;
- composition of bars by instance;
- visual display editor;
- notification rules;
- visible and verifiable battery charge limits;
- hardware integrations in optional modules.

## Consolidated functional matrix

| Domain | Ryoku | Caelestia | Noctalia v5 | DMS |
| --- | :---: | :---: | :---: | :---: |
| Multi-screen bar | Yes | Yes | Yes | Yes |
| Composable bar by widgets | Advanced | Limited | Advanced | Very advanced |
| Dock | Yes | Non-central | Yes | Yes |
| Launcher at providers | Yes | Yes | Yes | Yes |
| Emoji integrated into the launcher | Non-central | Non-central | Yes | Plugin/external |
| Dashboard | Yes | Great | Control Center | Yes |
| Control Center | Panels | Popouts/Nexus | Yes | Yes, expandable |
| Notifications + history | Yes | Yes | Yes | Yes |
| Notification rules | Limited | Limited | Filters | Yes |
| Text/image clipboard | Yes | Yes | Yes | Yes |
| Fund: library | Very advanced | Great | Advanced | Advanced |
| Online funds | Wallhaven/Steam | CLI | Plugins/API | Extensions |
| Automatic rotation | Yes | Yes | Yes | Yes |
| Palette from bottom | Yes | Yes | Yes | Yes |
| App Themes | Pallet Bridge | CLI | Templates | Matugen very wide |
| Scheduled Light/Dark Mode | Yes | Yes | Yes | Yes |
| Hyprland Deep Settings | Great | Weak | Non-invasive | Advanced |
| Visual screen editor | Yes | Partial | Outside the scope | Great |
| Keyboard/Mouse Inputs | Yes | Minimal | Outside the scope | Yes |
| Audio by app | Yes | Yes | Yes | Yes |
| Wi-Fi/Ethernet/VPN | Yes | Yes | Yes | Yes |
| Bluetooth and pairing | Yes | Yes | Yes | Yes |
| Battery/Profiles/Charging | Yes | Status | Yes | Yes |
| Capture + annotation | Yes | Registration | Yes | Capture |
| Lock PAM | Yes | Yes | Yes | Yes |
| Greeter | SDDM | No | Separate project | Greetd |
| Desktop Widgets | Yes | Clock/visual | Yes | Yes |
| Plugins/extensions | Yes | Non-central | Yes | Yes |
| Global settings search | Excellent | Navigation | Yes | Excellent |
| Draft + apply | Yes | Direct | Overrides | Mixed |
| IPC/CLI | Yes | Yes | Very complete | Yes |
| Multi-composer | Hyprland/Niri | Hyprland | Very wide | Large |

## Consequence for Nord Violet

The current “Appearance” page seems useless because it mixes
adjustments without producing a visible experience. The four references separate
clearly three uses:

1. **Style**: palette, surfaces, typography, movement and overall overview;
2. **Funds**: library, selection, automation and palette generation;
3. **Desktop and windows**: bar, dock, widgets, gaps, borders and rules.

Nord Violet must therefore replace “Appearance” with these three entries. The
Next recommended implementation is:

- integrate the emoji into the launcher/tools with a common DA, instead of one
  generic standalone window;
- first build **Style** with a real overview and few commands;
- keep **My screen** for material and layout;
- then create **Desktop** for the bar, widgets and behavior;
- report the expert options Hyprland in a searchable Advanced mode.

## Audit limitations

- an entry present in the code can be experimental, conditional or
  depend on an external binary;
- the DMS inventory voluntarily includes the 786 entries in its index, even if
  some are titles, subsections or conditional variants;
- inventories can be regenerated with
  `maquettes/audits/generate-rice-inventories.sh` after updating clones.
