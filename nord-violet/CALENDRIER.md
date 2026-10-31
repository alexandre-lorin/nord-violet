# Date et calendrier — 19 septembre 2026

Choix validé par Toubi : **survol B + calendrier A**, d’après `maquettes/calendrier.html`.

- Survol de l’heure : jour en grand, jour de semaine et mois/année en français.
- Clic droit : calendrier compact de 332 × 372 px sur l’écran utilisé.
- Semaine commençant lundi, jours voisins atténués, sélection violette discrète,
  point sous aujourd’hui, flèches de mois et bouton Aujourd’hui.
- Échap, clic extérieur ou nouveau clic droit sur l’heure : fermeture.
- Flèches clavier : sélection du jour ; Page précédente/suivante : mois ;
  Début : aujourd’hui. La sélection sert à consulter une date, sans agenda externe.
- Un seul calendrier ouvert à la fois. Depuis un calendrier ouvert, un clic sur
  l’autre écran le ferme ; le clic suivant ouvre celui de cet écran.

## Intégration

`CalendarHub.qml`, chargé par le shell du Control Center, crée une petite surface
d’entrée transparente au-dessus de chaque horloge native Waybar. L’heure reste
affichée par Waybar. Cette surface permet le vrai survol B à deux colonnes,
que le tooltip Pango natif ne permet pas de composer proprement.

`CalendarClock.qml` gère le survol, le clic droit et les surfaces layer-shell.
`CalendarCard.qml` et `CalendarButton.qml` utilisent les couleurs partagées de
`theme/Theme.qml`. `CalendarMath.js` calcule les dates à midi local pour éviter
les décalages lors des changements d’heure.

Le calendrier est ancré avant affichage : aucune fenêtre flottante à déplacer
après ouverture. Aucun espace spécial supplémentaire. La fermeture extérieure
utilise `HyprlandFocusGrab` sur le calendrier uniquement : inclure la surface
de l’horloge dans la capture provoquait la perte du deuxième clic sans mouvement.

Les deux fichiers Waybar actifs sont surveillés pour suivre la position haut/bas,
la hauteur, les marges et la présence de l’horloge centrale. L’espacement entre
barre et popup est de 12 px. La zone d’entrée mesure 66 px de large, adaptée au
format actuel `HH:MM` ; revoir cette largeur si le format ou la police change.
La configuration actuelle utilise des sorties nommées explicitement dans
`config.jsonc`, reprises par le calendrier. Un changement vers des motifs de
sortie Waybar demanderait d’adapter cette correspondance.

Le tooltip natif est désactivé dans le fichier actif
`~/.config/waybar/modules-common.jsonc`. `opacity.css` n’a pas été modifié.
Le dossier Waybar actif reste indépendant de sa copie ancienne dans Git.

## Validation

- Six cycles réels sur HDMI-A-1 et eDP-1 : survol, clic droit, fermeture par
  Échap / clic droit / clic extérieur. Positions contrôlées via le compositeur.
- Navigation au mois suivant et retour à aujourd’hui vérifiés visuellement.
- Passage entre écrans contrôlé : un seul calendrier visible.
- Barre temporairement placée en haut : calendrier ancré à y=46, puis retour
  exact au fichier et à la disposition d’origine.
- Neuf tests de dates : années bissextiles, changement d’année, changement
  d’heure, grille du lundi au dimanche et navigation au clavier.
- Les huit tests existants de placement des flyouts passent également.
- `qmllint` passe sur CalendarCard et CalendarButton. Sur CalendarClock et
  CalendarHub, il quitte avec le code 255 sans diagnostic ; leur chargement réel
  et les interactions ci-dessus ont été vérifiés sans nouvelle erreur QML.
- Aucune erreur de configuration Hyprland ; `git diff --check` passe.

Commandes reproductibles depuis `/home/toubi/dotfiles` :

```sh
TZ=Europe/Paris node --test nord-violet/tests/test_calendar.cjs
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s nord-violet/tests -v
```

Sauvegarde préalable :
`~/.local/state/nord-violet/backups/20260919-224328-calendar/`.
Les nouveaux composants Calendar et CalendarMath sont séparés des fichiers
existants. Pour retirer l’intégration, restaurer `shell.qml`, `qmldir` et
`modules-common.jsonc` depuis cette sauvegarde, puis recharger Waybar.
