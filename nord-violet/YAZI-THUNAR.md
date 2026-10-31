# Yazi et Thunar — 5 octobre 2026

## Thunar : prototype A appliqué

Retouche après retour utilisateur : panneau latéral violet sombre de 210 px, navigation avec bouton actif violet, barre d’outils plus espacée, en-têtes de colonnes contrastés, dates courtes `jour/mois · heure`, colonnes resserrées et barre d’état plus fine. CSS contrôlé avec Gtk.CssProvider et capture réelle de la fenêtre. Les menus, favoris et actions restent natifs.

Liste détaillée par défaut ; icônes de 24 px ; lignes d’environ 40 px ; colonnes Nom, Type, Taille, Date ; panneau favoris de 198 px ; chemin en boutons ; menu principal accessible par le bouton ⋮ plutôt que la barre de menus.

Icônes de dossiers SVG locales dans `~/.local/share/icons/NordViolet`, reproduisant la silhouette violette de la maquette. Les autres icônes héritent de Papirus-Dark. Le thème est sélectionné dans GTK 3 et dans `org.gnome.desktop.interface icon-theme` : les autres applications GTK peuvent aussi afficher ces dossiers violets. Aucun fichier d’icônes système modifié.

Préférences reproductibles avec `bash ~/dotfiles/thunar/apply-preferences.sh`. CSS ciblé sur `.thunar`, dans le paquet GTK existant. Icônes et actions sauvegardées dans le paquet Git `thunar`. Pas de commit créé.

Rendu réel contrôlé dans `~/.config/hypr`. Adaptation native, pas remplacement de Thunar : le menu, les intitulés de colonnes et les boutons de chemin restent ceux de GTK.

Pour revenir aux icônes précédentes : `gsettings set org.gnome.desktop.interface icon-theme Papirus-Dark` et remettre `gtk-icon-theme-name=Papirus-Dark` dans `~/.config/gtk-3.0/settings.ini`. Pour réafficher la barre de menus : `xfconf-query -c thunar -p /last-menubar-visible -s true`.

## Yazi

Affinage du 6 octobre : `Super+E` ouvre Yazi dans Alacritty, au dossier personnel ; `Super+Shift+E` conserve Thunar. Liste centrale élargie (colonnes 1:4:3), dossiers violets, barre d’état plus discrète et séparateurs harmonisés. Aucun plugin ou dépendance ajouté.

Configuration active dans `~/.config/yazi`, copie dans le paquet Git `yazi`.
Zed est installé sous `zeditor` (l’alias interactif `zed` ne fonctionne pas dans les commandes lancées par Yazi).

| Touche | Action |
| --- | --- |
| `e` | Modifier la sélection / le fichier survolé dans Zed |
| `Alt+n` | Modifier dans Neovim, dans le terminal courant |
| `o` | Ouvrir avec les règles habituelles, Zed pour texte / configs |
| `O` | Choisir une application, dont Neovim pour les fichiers texte |
| `g c` | Configurations |
| `g h` | Hyprland |
| `g y` | Configuration Yazi |
| `g w` | Waybar |
| `g s` | Shell Nord Violet |
| `g f` | Dotfiles Git |
| `g p` | Projets de développement |
| `g d` | Téléchargements |
| `Entrée` | Quitter et conserver le dossier pour la fonction shell `y` (comportement antérieur conservé) |

Raccourcis natifs conservés : `y` copier, `x` couper, `p` coller, `r` renommer, `a` créer, `.` masquer/afficher les fichiers cachés, `~` aide. Aucun plugin ajouté. Aucun changement à Neovim.

## Thunar

- Actions clic droit : Ouvrir dans Zed, Modifier dans Neovim, Parcourir avec Yazi (dossiers), Ouvrir un terminal ici.
- Favoris : Configurations, Hyprland, Dotfiles (Git) ; les autres entrées sont conservées.
- Panneau latéral configuré sur les favoris via `xfconf-query -c thunar -p /last-side-pane -s THUNAR_SIDEPANE_TYPE_SHORTCUTS`.
- Thème existant Breeze-Dark / Papirus-Dark conservé. CSS Nord Violet : barre d’outils mate, survol violet, barre d’état plus discrète.
- Zed était déjà l’application par défaut pour `text/plain` ; pas de modification globale des associations MIME.

Copies Git dans `thunar/.config/Thunar/uca.xml` et `thunar/.config/gtk-3.0/bookmarks`. CSS dans le paquet existant `nord-violet`. Pas de migration Stow des dossiers actifs.

## Validation

TOML et XML parsés ; démarrage réel Yazi réussi ; captures de Yazi et Thunar contrôlées. Les actions ouvrant Zed / Neovim ne sont pas déclenchées sur des fichiers personnels pendant les tests.
