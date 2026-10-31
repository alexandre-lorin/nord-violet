# Son et wlogout — finalisation du 20 septembre 2026

## Panneau Son

Le panneau audio reprend la présentation du calendrier : largeur de 332 px,
fond `Theme.surface`, bordure neutre, rayon de 18 px, police Inter et marges de
20 px. Le violet marque le volume et la sortie sélectionnée. La bordure externe
Hyprland est désactivée uniquement pour ce panneau, dont QML dessine le contour.

Chaque sortie comporte un nom court et une ligne de contexte :

| Sortie | Sous-texte |
| --- | --- |
| Écran MFG27F4Q | HDMI / DisplayPort |
| Elgato Wave:3 | Retour casque · USB |
| Haut-parleurs du portable | Audio intégré |
| HyperX Cloud III | Casque · USB |

`scripts/audio-devices.py` produit ces libellés à partir des propriétés des
appareils. Les scripts `audiosink.sh` et `audiosinks.sh` l'utilisent également :
les noms sont donc partagés avec le Control Center et ses réglages. Les noms
internes PipeWire ne sont pas modifiés et restent les cibles des commandes.

Le panneau affiche l'état muet séparément du volume mémorisé et propose un
bouton pour couper/rétablir le son. Le curseur fonctionne à la souris, à la
molette et au clavier. Les changements externes sont relus chaque seconde
pendant l'affichage. La liste ne se reconstruit que si ses données changent.

Le mécanisme de placement v47 est conservé : taille calculée explicitement,
position confirmée avant révélation, sans animation de déplacement. Avec les
quatre sorties actuelles, le panneau mesure 332 × 464 px. Au-delà de la hauteur
maximale, la liste défile.

La sélection continue de changer la sortie par défaut, comme auparavant.
Ce travail ne force pas la migration des flux déjà dirigés explicitement vers
un autre appareil.

Le 23 septembre, cette politique a été centralisée dans `audio-devices.py` :
le popup, le Control Center, la page Audio, Waybar, les touches multimédias et
l’OSD résolvent tous explicitement la sortie PipeWire par défaut. Les actions
de volume et de muet ne choisissent plus chacune leur cible séparément.

Dans Waybar, le clic gauche ouvre maintenant le panneau audio, le clic molette
coupe ou rétablit le son et le clic droit conserve `pavucontrol`. Les fichiers
actifs `modules-common.jsonc`, `flyout-trigger.sh` et `osd-trigger.sh` sont
désormais recopiés à l’identique dans le dépôt.

## Wlogout

**Ctrl + Échap** ouvre la variante A éditoriale épurée sur l'écran actif :
heure et date à gauche, cinq actions à droite. La composition est affichée à
1,5 fois la taille initiale. Les raccourcis L, U, E, R et S occupent une colonne
latérale séparée. Le rappel Échap n'est plus affiché, mais Échap ferme toujours
le menu.

Le fond est noir mat et l'accent violet reste réservé au focus et à la touche
active. Il n'y a ni icône ni glow. La composition du 23 septembre utilise un
panneau éditorial central : horloge affirmée à gauche, séparation verticale et
actions à droite. La première action est sélectionnée dès l’ouverture, avec un
repère violet fin et un encadrement discret. Déconnexion, redémarrage et
extinction demandent une confirmation ; verrouillage et veille restent directs.
Dans une confirmation, Entrée annule par défaut et Tab ou les flèches latérales
sélectionnent la confirmation.

Le menu est maintenant une surface Quickshell dédiée. `launch.py` choisit la
sortie Hyprland active, lit l'accent courant et transmet les cinq commandes du
layout existant sans les modifier. Sur un écran étroit, la composition se place
verticalement. Le mode aperçu remplace toutes les commandes système par `true`.

Pour revoir le rendu sans déclencher d'action système :

```sh
python3 ~/.config/wlogout/launch.py --preview
```

Ce mode utilise le composant Quickshell réel et neutralise les cinq commandes.

## Validation

- 25 tests Python réussis : neuf tests de noms/état/commandes audio, quatre tests du
  menu de session, quatre tests Falcon et huit tests de placement des flyouts.
- Cinq cycles audio sur HDMI-A-1 et eDP-1 : position finale correcte dès chaque
  premier échantillon visible, sans retour du saut à l'ouverture.
- Cinq cycles Wi-Fi supplémentaires : positions finales correctes ; la taille
  peut toujours évoluer avec les résultats du scan, comportement préexistant.
- Interactions audio réelles : mute sans modification du volume mémorisé,
  réglage du volume au clavier, sélection de la sortie courante. Valeurs brutes
  des canaux et état muet restaurés après essai.
- Le menu éditorial a été vérifié visuellement à l'échelle 1,5 sur HDMI-A-1 et
  eDP-1. Les cinq raccourcis, l'annulation et la confirmation ont été exercés
  avec les actions neutralisées. Aucune déconnexion, veille, extinction ou
  opération de redémarrage n'a été exécutée pour ces tests.
- `qmllint` sur AudioFlyout, syntaxe des wrappers Bash, configuration Hyprland
  et `git diff --check` passent.
- Le 20 septembre, le nouveau processus du Control Center charge la
  configuration. Il signale un avertissement d'enregistrement auprès du portail
  de bureau ; aucune erreur de chargement QML n'est signalée.

Depuis `/home/toubi/dotfiles` :

```sh
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s nord-violet/tests -v
qmllint -I /usr/lib/qt6/qml quickshell-cc/.config/quickshell/nord-violet-cc/AudioFlyout.qml
```

Sauvegarde préalable :
`~/.local/state/nord-violet/backups/20260919-230411-audio-wlogout/`.
Captures et mesures : `~/.local/state/nord-violet/audio-wlogout-20260919/`.
Recette éditoriale : `~/.local/state/nord-violet/wlogout-editorial-20260921/`.
Sauvegarde avant intégration :
`~/.local/state/nord-violet/backups/wlogout-editorial-20260921-225452/`.
Aucun commit créé.
