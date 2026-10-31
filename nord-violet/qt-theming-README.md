# Qt theming — not draftable into a file

Unlike GTK, Qt has no simple equivalent to gtk.css. The standard path:

1. Install `qt5ct` / `qt6ct` (or `qt6gtk2` to directly inherit the GTK theme, simpler but less refined)
2. Env variables needed in `hyprland.conf` or `~/.config/environment.d/`:
   ```
   env = QT_QPA_PLATFORMTHEME,qt5ct
   ```
3. For a real Nord Violet match, you need a custom Kvantum theme (.kvconfig file + .svg of the palette) — it's a project in its own right, not a simple color override.

Undraftable from a distance without the risk of going off on the wrong track. To be dealt with in real session, not here.
