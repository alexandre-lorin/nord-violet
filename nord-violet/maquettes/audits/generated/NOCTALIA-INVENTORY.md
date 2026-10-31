# Noctalia v5 — inventory extracted from code

Local source: `/home/toubi/01 - Dev/00 - Projets à tester/cpp--noctalia`  
Revision: `f0339ef6c6e7a13b027bd623bd48201bbeda29ab`

## Complete configuration provided by the project


### `[accessibility]`

-`ui_scale              = 1.0`
-`high_contrast         = false`

### `[shell]`

-`corner_radius_scale   = 1.0`
-`font_family           = "sans-serif"`
-`time_format           = "{:%H:%M}"`
-`date_format           = "%A, %x"`
-`offline_mode          = false`
-`telemetry_enabled     = false`
-`niri_overview_type_to_launch_enabled = false`
-`polkit_agent          = false`
-`password_style        = "default"`
-`settings_show_advanced = true`
-`show_location         = true`
-`clipboard_enabled     = true`
-`clipboard_history_max_entries = 100`
-`clipboard_keep_from_closed_apps = true`
-`clipboard_auto_paste  = "auto"`
-`clipboard_image_action_command = ""`
-`shared_gl_context     = true`

### `[shell.screenshot]`

-`skip_annotate_on_copy_save = false`
-`close_on_copy = true`
-`close_on_save = true`

### `[shell.privacy]`

-`mic_filter_regex = ""`
-`cam_filter_regex = ""`
-`screen_filter_regex = ""`

### `[shell.animation]`

-`enabled = true`
-`speed   = 1.0`

### `[shell.shadow]`

-`direction = "down"`
-`alpha     = 0.55`

### `[shell.panel]`

-`transparency_mode     = "solid"`
-`borders               = true`
-`shadow                = true`
-`launcher_placement       = "floating"`
-`clipboard_placement      = "floating"`
-`control_center_placement = "attached"`
-`wallpaper_placement      = "attached"`
-`session_placement        = "attached"`
-`launcher_position        = "center"`
-`clipboard_position       = "center"`
-`open_near_click_control_center = false`
-`open_near_click_launcher       = false`
-`open_near_click_clipboard      = false`
-`open_near_click_wallpaper      = false`
-`open_near_click_session        = false`

### `[shell.launcher]`

-`categories    = true`
-`show_icons    = true`
-`show_app_origin_indicator = true`
-`compact       = false`
-`app_grid      = false`
-`sort_by_usage = true`
-`pinned        = []`
-`fetch_exchange_rates = true`
-`provider_prefix = "/"`
-`auto_paste = "auto"`

### `[shell.launcher.providers.calculator]`

-`prefix = "calc"`
-`global = true`

### `[shell.launcher.providers.emoji]`

-`prefix = "emo"`

### `[shell.launcher.providers.session]`

-`prefix = "session"`
-`global = false`

### `[shell.launcher.providers.wallpaper]`

-`prefix = "wall"`

### `[shell.launcher.providers.windows]`

-`prefix = "win"`

### `[shell.mpris]`

-`blacklist = []`

### `[shell.window_switcher]`

-`style = "carousel"`
-`mru = false`
-`show_caption = true`
-`show_count = true`
-`show_app_icon = true`

### `[wallpaper]`

-`enabled             = true`
-`fill_mode           = "crop"`
-`fill_color          = ""`
-`transition          = ["fade", "wipe", "disc", "stripes", "zoom", "honeycomb"]`
-`transition_duration = 1500`
-`edge_smoothness     = 0.3`
-`transition_on_startup = false`
-`directory           = ""`
-`directory_light     = ""`
-`directory_dark      = ""`

### `[wallpaper.default]`

-`path = ""`

### `[wallpaper.automation]`

-`enabled                    = false`
-`interval_seconds           = 1800`
-`order                      = "random"`
-`recursive                  = true`

### `[theme]`

-`mode   = "dark"`
-`source = "builtin"`
-`builtin = "Noctalia"`
-`pure_black_dark = false`

### `[theme.templates]`

-`enable_builtin_templates            = true`
-`builtin_ids                = []`
-`enable_community_templates = true`
-`community_ids              = []`

### `[backdrop]`

-`enabled                = false`
-`blur_intensity         = 0.5`
-`tint_intensity         = 0.3`

### `[notification]`

-`enable_daemon      = true`
-`show_app_name      = true`
-`show_actions       = true`
-`keep_dismissed_in_history = true`
-`layer              = "top"`
-`scale              = 1.0`
-`background_opacity = 0.97`
-`offset_x           = 20`
-`offset_y           = 8`

### `[osd]`

-`position = "top_right"`
-`position_vertical = "top_center"`
-`orientation = "horizontal"`
-`scale = 1.0`
-`background_opacity = 0.97`
-`offset_x = 20`
-`offset_y = 8`

### `[osd.kinds]`

-`volume = true`
-`volume_output = true`
-`volume_input = true`
-`brightness = true`
-`wifi = true`
-`bluetooth = true`
-`power_profile = true`
-`caffeine = true`
-`nightlight = true`
-`dnd = true`
-`lock_keys = true`
-`keyboard_layout = true`
-`privacy = true`

### `[lockscreen]`

-`enabled                 = true`
-`blurred_desktop         = false`
-`transition              = ["fade", "wipe", "disc", "stripes", "zoom", "honeycomb"]`
-`transition_duration     = 1500`
-`edge_smoothness         = 0.3`
-`blur_intensity          = 0.5`
-`tint_intensity          = 0.3`

### `[system.monitor]`

-`enabled = true`
-`cpu_poll_seconds = 2.0`
-`cpu_freq_activity_threshold = 2.5`
-`cpu_freq_critical_threshold = 4.5`
-`gpu_poll_seconds = 5.0`
-`memory_poll_seconds = 2.0`
-`network_poll_seconds = 3.0`
-`disk_poll_seconds = 10.0`

### `[calendar]`

-`enabled                     = false`
-`refresh_minutes             = 15`
-`event_date_format           = "%A %e %B"`
-`event_time_format           = "%H:%M"`

### `[calendar.reminders]`

- `enabled              = true`
- `use_event_reminders  = true`
- `default_lead_minutes = 10`
- `all_day_digest_time  = "09:00"`

### `[control_center.calendar]`

- `show_events_card            = true`
- `show_week_numbers           = false`

### `[weather]`

- `enabled         = false`
- `refresh_minutes = 30`
- `unit            = "celsius"`
- `effects         = true`

### `[audio]`

- `enable_overdrive = false`
- `enable_sounds = false`
- `sound_volume = 0.5`
- `sound_theme = "freedesktop"`

### `[brightness]`

- `enable_ddcutil = false`

### `[nightlight]`

- `enabled              = false`
- `force                = false`
- `temperature_day      = 6500`
- `temperature_night    = 4000`

### `[location]`

- `auto_locate      = false`
- `address          = ""`

### `[idle.behavior.lock]`

- `timeout = 600`
- `action = "lock"`
- `enabled = false`

### `[idle.behavior.screen-off]`

- `timeout = 660`
- `action = "screen_off"`
- `enabled = false`

### `[keybinds]`

- `validate = ["return", "kp_enter", "space"]`
- `cancel   = ["escape"]`
- `left     = ["left"]`
- `right    = ["right"]`
- `up       = ["up"]`
- `down     = ["down"]`
- `tab_next = ["tab"]`
- `tab_previous = ["shift+iso_left_tab"]`
- `delete   = ["del"]`

### `[bar.main]`

- `position           = "top"`
- `thickness          = 34`
- `background_opacity = 1.0`
- `radius             = 12`
- `margin_ends        = 180`
- `margin_edge        = 10`
- `padding            = 14`
- `widget_spacing     = 6`
- `scale              = 1.0`
- `font_scale         = 1.0`
- `shadow             = true`
- `auto_hide          = false`
- `reserve_space      = true`
- `capsule            = false`
- `start  = ["launcher", "wallpaper", "workspaces"]`
- `center = ["clock"]`
- `end    = ["media", "tray", "notifications", "clipboard", "network", "bluetooth", "volume", "brightness", "battery", "control-center", "session"]`

### `[dock]`

- `enabled             = false`
- `position            = "bottom"`
- `icon_size           = 48`
- `main_axis_padding   = 16`
- `cross_axis_padding  = 8`
- `item_spacing        = 6`
- `background_opacity  = 0.88`
- `radius              = 16`
- `radius_top_left     = 16`
- `radius_top_right    = 16`
- `radius_bottom_left  = 16`
- `radius_bottom_right = 16`
- `margin_ends         = 0`
- `margin_edge         = 8`
- `shadow              = true`
- `show_running        = true`
- `auto_hide           = false`
- `reserve_space       = true`
- `layer               = "top"`
- `active_scale        = 1.0`
- `inactive_scale      = 0.85`
- `magnification       = true`
- `magnification_scale = 1.45`
- `active_opacity      = 1.0`
- `inactive_opacity    = 0.85`
- `show_dots           = false`
- `show_instance_count = true`
- `launcher_position   = "none"`
- `launcher_icon       = "grid-dots"`
- `active_monitor_only = false`
- `pinned              = []`

### `[desktop_widgets]`

- `enabled = false`

### `[hooks]`


## Documentation fonctionnelle

- automation/hooks.mdx
- bar/actions.mdx
- bar/index.mdx
- bar/widgets/active-window.mdx
- bar/widgets/audio-visualizer.mdx
- bar/widgets/battery.mdx
- bar/widgets/bluetooth.mdx
- bar/widgets/brightness.mdx
- bar/widgets/caffeine.mdx
- bar/widgets/clipboard.mdx
- bar/widgets/clock.mdx
- bar/widgets/control-center.mdx
- bar/widgets/custom-button.mdx
- bar/widgets/index.mdx
- bar/widgets/keyboard-layout.mdx
- bar/widgets/launcher.mdx
- bar/widgets/lock-keys.mdx
- bar/widgets/media.mdx
- bar/widgets/network.mdx
- bar/widgets/nightlight.mdx
- bar/widgets/notifications.mdx
- bar/widgets/power-profile.mdx
- bar/widgets/privacy.mdx
- bar/widgets/screenshot.mdx
- bar/widgets/session.mdx
- bar/widgets/settings.mdx
- bar/widgets/spacer.mdx
- bar/widgets/sysmon.mdx
- bar/widgets/taskbar.mdx
- bar/widgets/text.mdx
- bar/widgets/theme-mode.mdx
- bar/widgets/tray.mdx
- bar/widgets/volume.mdx
- bar/widgets/wallpaper.mdx
- bar/widgets/weather.mdx
- bar/widgets/workspaces.mdx
- composer-settings/hyprland.mdx
- composer-settings/kde.mdx
- compositor-settings/labwc.mdx
- composer-settings/mango.mdx
- composer-settings/niri.mdx
- compositor-settings/sway-scroll.mdx
- compositor-settings/umbriel.mdx
- configuration/date-format-tokens.mdx
- configuration/index.mdx
- configuration/secret-service.mdx
- configuration/shell.mdx
- control-center/index.mdx
- control-center/shortcuts.mdx
- desktop/wallpaper.mdx
- desktop/widgets.mdx
- dock/index.mdx
- getting-started/faq.mdx
- getting-started/installation.mdx
- getting-started/nixos.mdx
- getting-started/running-the-shell.mdx
- getting-started/uninstall.mdx
- index.mdx
- ipc/index.mdx
- ipc/media-and-ui.mdx
- ipc/plugins.mdx
- ipc/shell-and-ui.mdx
- ipc/shell.mdx
- ipc/surfaces.mdx
- ipc/system-controls.mdx
- launcher/index.mdx
- lockscreen/widgets.mdx
- plugins/development/declarative-ui.mdx
- plugins/development/entries.mdx
- plugins/development/index.mdx
- plugins/development/manifest.mdx
- plugins/development/plugin-api.mdx
- plugins/development/runtime-api.mdx
- plugins/development/workflow.mdx
- plugins/index.mdx
- plugins/official-plugins.mdx
- services/audio.mdx
- services/battery.mdx
- services/brightness.mdx
- services/calendar.mdx
- services/idle.mdx
- services/location.mdx
- services/night-light.mdx
- services/notifications.mdx
- services/system-monitor.mdx
- services/weather.mdx
- templates/community/discord.mdx
- templates/community/firefox.mdx
- templates/community/neovim.mdx
- templates/community/obsidian.mdx
- templates/community/spotify.mdx
- templates/community/steam.mdx
- templates/community/terminal-templates.mdx
- templates/community/vscode.mdx
- templates/community/zenbrowser.mdx
- templates/official/emacs.mdx
- templates/official/gtk-qt.mdx
- templates/official/umbriel.mdx
- theming/app-theming.mdx
- theming/index.mdx
- theming/palette.mdx
- theming/templates.mdx

## Shell surfaces

- backdrop
- bar
- bar/widgets
- clipboard
- control_center
- control_center/tabs
- desktop
- desktop/editor
- desktop/widgets
- dock
- greeter
- hot_corners
- launcher
- lockscreen
- notification
-osd
- overview
- panel
- polkit
- profile
- screen_corners
- session
- settings
- setup_wizard
- area
- switch
- test
-tooltip
- tray
-wallpaper
- wallpaper/panel

## System integrations and composers

- accounts
- bluetooth
- dwl
- ext_workspace
- hyprland
- idle
- kde
- labwc
- logind
- mango
- modem
- mpris
- network
- niri
- notification
- polkit
- power
- sway
- tray
- triad
- umbriel
- upower

## Modèles d’applications livrés

- alacritty
- btop
- cava
- emacs
- foot
- ghostty
- gtk
- helix
- hyprland
- kde
- kitty
- labwc
- mango
- niri
- qt
- scroll
- starship
- sway
- umbriel
- wezterm
