# Yazi and Thunar — 5 October 2026

## Thunar: prototype A applied

Rework after user feedback: 210 px dark purple side panel, navigation with purple hot button, more spaced toolbar, contrasting column headers, `jour/mois · heure` short dates, narrower columns and thinner status bar. CSS controlled with Gtk.CssProvider and actual window capture. Menus, favorites and actions remain native.

Detailed list by default; 24 px icons; lines of approximately 40 px; columns Name, Type, Size, Date; 198 px favorites panel; button path; main menu accessible by the ⋮ button rather than the menu bar.

Local SVG folder icons in `~/.local/share/icons/NordViolet`, replicating the purple silhouette of the mockup. The other icons inherit from Papirus-Dark. The theme is selected in GTK 3 and in `org.gnome.desktop.interface icon-theme`: other GTK applications can also display these purple folders. No modified system icon files.

Preferences reproducible with `bash ~/dotfiles/thunar/apply-preferences.sh`. CSS targeted to `.thunar`, in the existing GTK package. Icons and actions saved in Git package `thunar`. No commit created.

Actual rendering controlled in `~/.config/hypr`. Native adaptation, not replacement of Thunar: the menu, column titles and path buttons remain those of GTK.

To return to the previous icons: `gsettings set org.gnome.desktop.interface icon-theme Papirus-Dark` and put `gtk-icon-theme-name=Papirus-Dark` back into `~/.config/gtk-3.0/settings.ini`. To redisplay the menu bar: `xfconf-query -c thunar -p /last-menubar-visible -s true`.

## Yazi

Refinement of 6 October: `Super+E` opens Yazi in Alacritty, in the personal folder; `Super+Shift+E` keeps Thunar. Expanded central list (1:4:3 columns), purple folders, more discreet status bar and harmonized separators. No plugins or dependencies added.

Active configuration in `~/.config/yazi`, copy to Git package `yazi`.
Zed is installed under `zeditor` (the interactive alias `zed` does not work in commands launched by Yazi).

| Key | Action |
| --- | --- |
| `e` | Edit selection/hovered file in Zed |
| `Alt+n` | Edit in Neovim, in the current terminal |
| `o` | Open with usual rules, Zed for text/configs |
| `O` | Choose an application, including Neovim for text files |
| `g c` | Settings |
| `g h` | Hyprland |
| `g y` | Yazi Setup |
| `g w` | Waybar |
| `g s` | Shell Nord Violet |
| `g f` | Git dotfiles |
| `g p` | Development projects |
| `g d` | Downloads |
| `Entrée` | Exit and keep folder for shell function `y` (previous behavior retained) |

Native shortcuts retained: `y` copy, `x` cut, `p` paste, `r` rename, `a` create, `.` hide/show hidden files, `~` helps. No plugins added. No changes to Neovim.

## Thunar

- Right click actions: Open in Zed, Modify in Neovim, Browse with Yazi (folders), Open a terminal here.
- Favorites: Configurations, Hyprland, Dotfiles (Git); other entries are retained.
- Side panel configured to favorites via `xfconf-query -c thunar -p /last-side-pane -s THUNAR_SIDEPANE_TYPE_SHORTCUTS`.
- Existing Breeze-Dark / Papirus-Dark theme retained. CSS Nord Violet: matte toolbar, purple hover, more discreet status bar.
- Zed was already the default application for `text/plain`; no global modification of MIME associations.

Git copies in `thunar/.config/Thunar/uca.xml` and `thunar/.config/gtk-3.0/bookmarks`. CSS in existing package `nord-violet`. No Stow migration of active folders.

## Validation

Parsed TOML and XML; Yazi real start successful; captures of Yazi and Thunar controlled. Actions opening Zed/Neovim are not triggered on personal files during testing.
