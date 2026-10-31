# Nord Violet — harmonisation du 17 septembre 2026

Dernier choix explicite de Toubi : accent commun **#9b7cff**.

## État appliqué

- Hyprland : bordures actives et accent de `palette.conf` alignés ; alpha
  de `accent_dim` conservé. La bordure de la session active a été mise à jour.
- Control Center et Waybar : même accent, y compris les points des workspaces.
- Mako : accent des notifications normales aligné ; rouge critique conservé.
- Alacritty : ajout de `alacritty.toml` important la palette existante ; curseur
  violet. Les couleurs ANSI Nord, dont le magenta `#b48ead`, gardent leur rôle.
- GTK 3 et GTK 4 : Breeze-Dark, Papirus-Dark, curseur `breeze_cursors` taille 24,
  Inter 10. Ces ressources sont installées. Les préférences GNOME correspondantes
  sont alignées, avec `prefer-dark` et JetBrains Mono 10 pour le monospace.
- GTK 4 importe la surcharge de couleurs GTK 3. Les anciennes définitions Breeze
  claires restent sur disque mais ne sont plus importées. L'accent libadwaita
  est également défini ; les fonds sélectionnés restent peu opaques.
- Hyprlock : accent aligné et commentaire corrigé. Le fond de verrouillage reste
  `halo-wallpaper-4k.jpg`, celui du bureau reste `wp1.png`.
- Fuzzel et wlogout : accents existants alignés. Aucune configuration Rofi ajoutée.

## Synchronisation

`~/.config/quickshell/nord-violet-cc/scripts/accentctl.sh` propage le choix
des Réglages aux fichiers actifs existants : Hyprland, Hyprlock, Waybar, Mako,
curseur Alacritty, GTK, Fuzzel et wlogout. Il ne génère pas les palettes complètes.
Les couleurs de danger, succès et ANSI restent indépendantes.

Les liens symboliques Stow et permissions sont conservés. Le script valide les
formats avant toute écriture, recharge Mako et Waybar et met à jour la bordure
Hyprland. Les applications GTK peuvent nécessiter une réouverture ; Hyprlock
applique ses couleurs au prochain verrouillage. Rouvrir les terminaux déjà
lancés s'ils n'ont pas chargé le nouveau fichier principal.

Attention : `~/.config/hypr/hyprlock.conf`, `~/.config/waybar/` et
`~/.config/gtk-4.0/` contiennent des fichiers actifs indépendants du dépôt.
Ne pas écraser ces dossiers avec un ancien paquet Stow. Les copies existantes
de `hyprlock.conf` et `waybar/colors.css` dans le dépôt ont été alignées pour
cette intervention ; les changements d'accent ultérieurs ciblent les fichiers actifs.

## Validation

- Tests isolés du script : propagation, préservation des liens Stow et alpha,
  couleurs sémantiques inchangées, rejet des arguments et formats invalides.
- `bash -n` : script d'accent et points de workspaces valides.
- `qmllint` : aucun diagnostic sur Colors.qml et AppearancePage.qml.
- Quickshell : rechargement réel confirmé par `Configuration Loaded`.
- Hyprland : aucune erreur de configuration ; bordure active `ff9b7cff`.
- Mako : rechargement réussi.
- GTK 3 et GTK 4 : CSS chargé sans erreur par les parseurs installés ; réglages
  effectifs lus dans Gtk.Settings. Libadwaita confirme le mode sombre.
- Alacritty : TOML valide, import accepté par `migrate --dry-run --silent`.
- `git diff --check` : réussi. Aucun commit créé.

La recette visuelle complète des applications et du verrouillage reste à faire.
Le bac à sable signale son cache dconf en lecture seule ; les écritures via
GSettings ont néanmoins réussi, et les valeurs ont été relues dans GTK.

## Sauvegarde et reprise

Sauvegarde avant intervention :
`/home/toubi/.local/state/nord-violet/backups/20260917-221624/`.

`files.json` indique les chemins, leurs cibles et leur existence avant intervention.
`gsettings.json` conserve les anciennes valeurs des seules préférences modifiées.
Pour restaurer, recopier les fichiers sauvegardés vers leurs cibles indiquées,
en préservant les liens ; le fichier principal Alacritty était absent auparavant.
Restaurer les préférences avec `gsettings set`, puis recharger les composants.

La transmission Claude originale est conservée dans les téléchargements.
Son `CONTEXT.md` et son `CHANGELOG.md` vont jusqu'à v46 ; son `HANDOFF.md`
est ancien (v32). Le correctif audio v43 manque dans les trois fichiers actifs,
et les validations des correctifs Alacritty/Swappy v44–v46 restent un chantier
distinct, non modifié pendant cette harmonisation visuelle.
