# Falcon — accès rapide et contrôles

Intégration du 21 septembre 2026, approuvée par Toubi.

| Raccourci | Action |
|---|---|
| Super+B | Afficher/masquer Falcon sur le moniteur actif |
| Super+flèches | Focus entre fenêtres |
| Super+Maj+flèches | Déplacer la fenêtre |
| Super+Ctrl+flèches | Redimensionner par pas de 40 pixels |
| Ctrl+N dans Falcon | Ajouter selon la rubrique : objectif/directive, session ou journal |
| Ctrl+P dans Falcon | Saisir une commande |
| Tab / Maj+Tab | Rubrique suivante/précédente, ou champ du formulaire |
| Échap | Annuler, revenir à l’accueil, puis masquer le popup |

La barre conserve quatre surfaces : `m` Plan, `f` Focus/chrono, `j` Journal et
`b` Bilan. `t` ouvre Today, `c` les Cycles et `?` l’aide. Toutes partagent
directement les données de Folio.

Super+G reste le mode Travail/Jeu ; Super+D reste Discord. Les huit raccourcis
Hyprland de déplacement/redimensionnement HJKL deviennent les flèches.

## Lanceur

Source : `../hypr/.config/hypr/scripts/falcon-popup.py`, liée à
`~/.config/hypr/scripts/falcon-popup.py`. Dépendances déjà présentes : Python 3,
Hyprland, Alacritty et `~/.local/bin/falcon`.

Classe `falcon-popup`, espace spécial `nvfalcon`. La règle place la fenêtre
silencieusement dans cet espace dès sa création, flottante et sans animation.
Le lanceur calcule la taille dans la zone utilisable de l’écran, prépare la
position pendant que l’espace est masqué, attend que Hyprland confirme la
position et la taille, puis affiche et donne le focus. Il tient compte de la
rotation, de l’échelle et des marges réservées. Taille maximale 1400×850 ;
68 % de largeur et 75 % de hauteur utile sur les petits écrans.

Un verrou empêche les appels simultanés de créer plusieurs instances. Un rappel
sur l’autre écran déplace la même fenêtre ; masquer conserve la saisie et la
session. `q` ferme réellement le processus. L’environnement `FALCON_POPUP=1`
permet à Échap de masquer l’espace au lieu de quitter, uniquement dans le popup.
Les animations globales ne sont pas modifiées.

La configuration active `~/.config/hypr/windowrules.conf` est indépendante de
sa copie Git. Les trois règles Falcon ont été ajoutées aux deux fichiers sans
remplacer leurs autres différences. `keybinds.conf` reste un lien vers Git.

## Vérification et retour arrière

Tests sans bureau : `python3 tests/test_falcon_popup.py` depuis ce dossier.
Ils couvrent géométrie, changement d’écran, ordre placement/affichage et refus
d’afficher une position non confirmée. La recette native vérifie également la
même instance sur HDMI-A-1 puis eDP-1, les rappels rapides et Échap.

Sauvegardes avant changement :
`~/.local/state/falcon/backups/raccourcis-formulaires-20260921-200744/`.
Elles contiennent les raccourcis, les deux fichiers de règles et les sources
Falcon précédentes. Pour annuler uniquement les raccourcis, restaurer les lignes
concernées depuis ces copies et retirer les trois règles Falcon, puis lancer
`hyprctl reload`. Ne pas écraser aveuglément un fichier ayant reçu d’autres
modifications depuis.

Le guide du premier démarrage et les limites fonctionnelles sont dans
[README Falcon](</home/toubi/05 - Projets Perso/01 - En Cours/S-09/falcon/README.md>).
