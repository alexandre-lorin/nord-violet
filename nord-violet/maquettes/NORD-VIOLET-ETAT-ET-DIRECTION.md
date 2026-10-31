# Nord Violet — actual status and product direction

Audit of 25 September 2026. This document strictly separates what works
today of what is only planned.

## What Nord Violet actually has

### Shell and integration Hyprland

- Hyprland configuration split by domain and loaded by `source`;
- two groups of five workspaces, divided between HDMI-A-1 and eDP-1;
- navigation, moving and resizing windows using the keyboard;
- moving and resizing with the mouse;
- floating toggle with automatic size and recentering;
- Discord scratchpads, terminal, btop monitoring at 100 ms and Falcon;
- capture region, full screen and monitor with Swappy;
- Hyprlock, Wlogout session menu and idle command;
- Fuzzel launcher and Omni unified search;
- Cliphist clipboard;
- multimedia keys with OSD volume/brightness;
- emoji picker on `Super+N`, functional but visually rejected.

### Control Center

- contextual panel placed on the active monitor;
- output volume, choice of audio output and monitoring of PipeWire changes;
- active connection, up/down speed and Wi-Fi component;
- Wi-Fi activation, scan, connection and password entry;
- Do not disturb via Mako;
- Bluetooth status and connected device in reading;
- deletion of notifications;
- independent audio and Wi-Fi flyouts;
- opening animations, scrims and closing by Escape;
- local icon set and shared Nord Violet theme;
- access to Settings from a row fixed at the bottom of the panel.

### Current settings

- window 1280×820 with grouped side rail;
- search by page, direct navigation and Advanced mode;
- eight pages: Appearance, Backgrounds, Screens, Sound, Connections, Shortcuts, System
  and Hyprland;
- Appearance: choice of accent actually propagated, visual identity and overview;
- Funds: local library, miniatures, import, random selection, choice
  all screens or screen accurate, persistent application with Hyprpaper;
- Screens: active inventory, resolution, frequency, position and scale;
- Sound: volume and output choice;
- Connections: Wi-Fi, scan and connection;
- Shortcuts: reading and presenting the real `keybinds.conf`;
- System: machine, kernel, uptime, RAM, disk and load;
- Hyprland: version and active workspaces.

### Overall skin

- Nord Violet palette common to Hyprland, Waybar, Alacritty, GTK, Mako,
  Wlogout and Quickshell;
- editorial session menu with confirmation;
- personalized lock screen;
- multi-screen background and rules;
- HTML Atelier prototype serving as a visual reference.

## What does not yet exist

- graphic editor of monitors;
- Interactive Bluetooth;
- audio inputs and volumes per application;
- battery profiles, charge threshold and standby from Settings;
- editing shortcuts and detecting conflicts;
- configurable bar/dock/widgets;
- light/dark themes, typography and density truly editable;
- pallet automatically extracted from the bottom;
- automatic rotation of funds;
- notification rules by application;
- window rules Hyprland;
- save, diff, apply, undo and restore;
- extensions/plugins;
- search at the level of each option.

## Teachings from external references

### Apple

- A sidebar is used for large areas, remains shallow and can become
  retractable when the window shrinks.
- Critical actions should not live at the bottom of the sidebar: this
  area may be hidden or less noticed.
- A single action, exceptionally two, must be visually dominant
  in a view.
- A custom button must have rest, hover, press, wait states
  and result; a generous interaction area counts more than a large
  decor.
- Color is used for hierarchy and status, not to color all actions.

Application to Nord Violet: keep the left rail, remove the big gate
“Settings” at the bottom of the Control Center and avoid small decorative badges
around the rafters.

### GNOME

- A view should have a clear topic and a digestible amount of content.
- A hierarchy should normally only be one level deep.
- Views must change in the same window rather than multiplying them
  secondary windows.

Application: Control Center for immediate actions, Settings for
durable configuration, subpages only when a specific object requires it.

### KDE

- “Simple by default, powerful when necessary” corresponds exactly to the
  need Nord Violet.
- Actions are contextual, secondary functions go into a
  subpage or menu, and the interface adapts to the width.
- Icons alone are reserved for universal actions; otherwise the text
  must remain visible.
- A line should have zero or only one inline action, two at most.
- Direct manipulation is preferable: sliding the modules of a bar is
  better than Up/Down buttons.

Application: a transversal Advanced mode, visual editors for screens and
bar, and far fewer permanent buttons.

### Microsoft Fluent

- A simple adjustment should be reflected immediately; an Apply button does not
  only justified for a risky operation or a consistent batch.
- Toggle for a boolean, visible options for two to five choices, list
  compact beyond.
- A recurring order must be close to the item concerned.
- Wide pages must maintain a limited reading width.

Application: focus, volume, Wi-Fi and appearance applied live with Undo;
screens, rules Hyprland and import explicitly validated with preview of the diff.

### Jakob Nielsen

- make the state of the system visible;
- speak in the user’s words;
- promote recognition rather than memorization;
- prevent errors and provide undo/rollback;
- remain consistent and minimal.

Application: Show "applied", "reboot required" or "not supported
load” next to the control, and never present a false option.

### Linus Torvalds

Linus's public preferences have varied between KDE, GNOME, and Xfce over the years.
years. It is therefore not a stable aesthetic direction. The constant signal
is functional: it criticizes environments that remove controls
useful in the name of simplicity, especially when mouse behavior
or windows can no longer be adapted to its workflow.

Lesson for Nord Violet: provide excellent default, but leave functions
editable essentials. Advanced mode should not be a false decoration; he must
expose the real mechanisms and active values.

## Recommended visual direction

### Structure

- dark and calm rail on the left, inspired by Ryoku;
- main editorial content, more airy, inspired by Caelestia;
- contextual preview on the right only for Style, Backgrounds, Bar and Screens;
- rail reducible to icons when the window becomes narrow;
- maximum depth: category → page → possible detailed sheet.

### Replacing the bottom buttons

The current buttons appear added after the content. The new rule must
be: no permanent global button bar if no modification is made
waiting.

- return: discreet button in the header or `Échap`;
- Settings from the Control Center: small action “Open settings…”
  in a menu `⋯`, plus `Super+S` as main access;
- current action: directly in the card concerned;
- instant changes: compact toast with “Cancel”;
- risky edits: floating action dock only when a draft
  exists, with summary `3 changements`, `Annuler` and a single purple action
  `Appliquer` ;
- reset: secondary menu of the page, never dominant button;
- destructive actions: dedicated area, explicit text and confirmation.

### Visual language

- purple reserved for selection, focus and main action;
- surfaces defined mainly by space, contrast and fine lines;
- only three departments: small control, map, large area;
- consistent line icons, without disparate Unicode glyphs;
- short titles, concrete descriptions and visible active values;
- short movement for feedback, larger morphic movement only
  to open a panel or move to a preview;
- fewer nested boxes: groups rely on spacing first.

## Smart functions to add to the workflow

### Priority 1

1. **Single command palette**: applications, files, system actions,
   settings, emoji, clipboard, windows and backgrounds in Omni.
2. **Universal search for settings**: each result opens the correct one
   control and briefly highlights it.
3. **Global Undo**: any instant action produces a possibility of undo.
4. **Context profiles**: Work, Nomad, Game and Night apply screens,
   energy, notifications, audio, background and layout.
5. **Reliable battery limit**: actual hardware status, applied threshold and explanation
   if the laptop does not support it.
6. **Focus mode**: DND, energy profile, dedicated applications and workspace in
   one action, with visible timer.

### Priority 2

7. Visual screen editor with automatic return if the new layout
   is not confirmed.
8. Drag-and-drop composable bar with live preview.
9. Per-app notification rules and notification summary
   silent.
10. Enriched clipboard: favorites, images, search, OCR and exclusion of secrets.
11. Contextual commands depending on the active application.
12. History of configuration changes with restoration by section.

### Priority 3

13. Palette generation from the bottom and reversible templates for
   applications.
14. Desktop widgets limited to those that provide real information.
15. Extensions signed or audited after heart stabilization.

## Proposed decision

The next model must focus on a single Workshop window including:

- simplified Ryoku rail;
- transitions and side preview inspired by Caelestia;
- pages `Style`, `Fonds`, `Bureau`, `Matériel`, `Système` and `Avancé`;
- no permanent row of buttons at the bottom;
- conditional floating action dock;
- emoji integrated into Omni rather than a visually isolated application.

This structure maintains the identity Nord Violet while removing elements
which currently give the impression of a transposed HTML mockup without any real
product logic.

## Design sources

- [Apple — Sidebars](https://developer.apple.com/design/human-interface-guidelines/sidebars)
- [Apple — Buttons](https://developer.apple.com/design/human-interface-guidelines/buttons)
- [GNOME — Navigation](https://developer.gnome.org/hig/guidelines/navigation.html)
- [KDE — Layout and navigation](https://develop.kde.org/hig/layout_and_nav/)
- [KDE — Simple by default](https://develop.kde.org/hig/simple_by_default/)
- [KDE—Icons](https://develop.kde.org/hig/icons/)
- [Microsoft — Guidelines for app settings](https://learn.microsoft.com/en-us/windows/apps/design/app-settings/guidelines-for-app-settings)
- [Microsoft — Commanding basics](https://learn.microsoft.com/en-us/windows/apps/design/basics/commanding-basics)
- [Nielsen Norman Group — 10 usability heuristics](https://www.nngroup.com/articles/ten-usability-heuristics/)
- [2009 interview with Linus Torvalds, reproduced on the Ubuntu list](https://lists.ubuntu.com/archives/ubuntu-bd/2009-February/003321.html)
