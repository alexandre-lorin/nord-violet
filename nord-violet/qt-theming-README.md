# Qt theming — pas draftable en un fichier

Contrairement à GTK, Qt n'a pas d'équivalent simple à gtk.css. Le chemin standard :

1. Installer `qt5ct` / `qt6ct` (ou `qt6gtk2` pour hériter direct du thème GTK, plus simple mais moins fin)
2. Variables d'env nécessaires dans `hyprland.conf` ou `~/.config/environment.d/` :
   ```
   env = QT_QPA_PLATFORMTHEME,qt5ct
   ```
3. Pour un vrai match Nord Violet, il faut un thème Kvantum custom (fichier .kvconfig + .svg de la palette) — c'est un chantier à part entière, pas un simple override de couleurs.

Non draftable à distance sans risque de partir sur une fausse piste. À traiter en vrai session, pas ici.
