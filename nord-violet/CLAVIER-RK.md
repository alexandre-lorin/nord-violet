# RK R98Pro et clavier intégré — 6 octobre 2026

Périphériques RK reconnus par Hyprland : `rk-r98pro` et `rk-r98pro-keyboard`. Clavier intégré principal : `at-translated-set-2-keyboard` ; certaines commandes du portable passent aussi par ITE / video-bus.

## Commandes

Capture physique du 7 octobre : Fn+F5 du RK émet XF86Tools (keycode 179), F5 seul émet F5 (keycode 71). Binding XF86Tools ajouté uniquement pour les périphériques RK. spotify-focus.py lance Spotify si nécessaire puis affiche sa fenêtre existante (bureau 15), sans modifier F5 seul. 50 tests Python passent ; focus réel Spotify vérifié. Les anciens mappings média restent des variantes compatibles, pas la preuve du signal de ce modèle.

- Molette RK et `Fn+F11/F12` : volume −/+ par 1 %, plafonné à 100 %, commande wpctl directe pour préserver la fluidité. Waybar et le menu audio suivent leur mécanisme de synchronisation existant ; pas d’OSD séparé à chaque cran audio RK.
- Clic molette / `Fn+F10` : mute, contrôle audio et OSD existants.
- `Ctrl` + molette (ou `Ctrl+Fn+F11/F12`) : luminosité de l’écran focalisé par 5 points. Écran intégré via brightnessctl, externe via DDC/CI. Pas de repli silencieux vers l’écran intégré si l’externe n’est pas accessible.
- `Fn+F7/F8/F9` : précédent / lecture-pause / suivant via playerctl ; `Fn+F6` : stop. Nécessite une application compatible MPRIS.
- Touches natives volume/luminosité du portable : comportement précédent inchangé (5 %).
- `Fn+F1` : Yazi ; `Fn+F2` : Firefox ; `Fn+F3` : gestionnaire mail configuré (actuellement Firefox, aucun client mail dédié installé) ; `Fn+F4` : calculatrice qalc en terminal ; `Fn+F5` : Spotify. F1..F12 seuls restent disponibles pour les applications.
- Retouche luminosité : popup supprimé ; cache du bus DDC pendant 30 secondes, worker conservé 700 ms entre crans et écriture DDC sans relecture automatique systématique (`--noverify`). Délais matériels DDC standard conservés. Fluidité réelle à revalider par Toubi.

Les événements audio de la molette et des touches Fn sont traités identiquement lorsqu’ils portent le même keysym. Les mappings visent le RK entier, pas exclusivement la molette.

## Implémentation et validation

### Portable Lenovo LOQ 15ARP9

Capture réelle du 8 octobre : Fn+F9 → XF86Favorites (372), Fn+F10 → XF86TouchpadOff (540), Fn+F11 → Ctrl+Alt+Tab (Control_L puis Alt_L puis Tab). Mapping : F9 ouvre Omni ; TouchpadOff désactive ELAN, TouchpadOn le réactive (contrepartie prévue, événement On pas encore capturé) ; F11 ouvre Omni Windows. Pas de détournement de F9/F10/F11 seuls ni du RK. Commande Hyprland device[elan06fa:00-04f3:327e-touchpad]:enabled true testée avec succès. F8 reste en attente de vérification ; les notes spéculatives suivantes sont historiques.

Correction Alt+Tab : dans v0.56.2 le traducteur legacy de `cyclenext` ignore l’argument `all` (vérifié dans DispatcherTranslator.cpp). Les bindings utilisent désormais `window-cycle.py`, qui parcourt les fenêtres des bureaux normaux sur tous les écrans et exclut fenêtres cachées, non mappées, scratchpads et surfaces Nord Violet. Alt+Maj+Tab inverse le parcours. Ordre stable de la liste des clients, pas MRU ni aperçu Windows. Changement de fenêtre réel vérifié puis focus initial restauré ; 47 tests passent. La touche applications du portable est reliée à Omni Windows via Super+Tab / XF86TaskPane, à confirmer physiquement. Les notes cyclenext ci-dessous sont historiques.

Touches supplémentaires configurées séparément : XF86AudioMicMute → micro par défaut (wpctl), XF86Calculator → qalc, XF86Display ou Super+P provenant du portable → page Écrans. F1–F3 et F5–F6 utilisent les commandes audio/luminosité déjà présentes. Alt+Tab et Alt+Maj+Tab ajoutés globalement : cyclenext dans le bureau courant, sans interface de sélection ni ordre MRU Windows ; Super+W conserve la palette Omni Windows.

Selon [Lenovo](https://download.lenovo.com/pccbbs/pubs/loq_15_16/html_en/EN/ref_hotkey_icons.html), l’étoile S est Lenovo Smart Key, le sélecteur d’écrans règle les affichages, et F11 avec rectangles représente l’affichage des applications en vignettes (pas forcément Alt+Tab). F8 mode avion, F9 Smart Key, F10 pavé tactile et l’événement exact F11 restent à capturer physiquement avant de les remapper. Ne pas ajouter une seconde bascule rfkill sans vérifier celle du noyau. Ne pas présenter ces touches comme déjà validées.

Configuration Hyprlang existante conservée. Le source de Hyprland **v0.56.2**, `src/config/legacy/ConfigManager.cpp`, confirme le drapeau `k` : liste de périphériques après la touche, noms séparés par des espaces ; préfixe `!` pour exclusion. Pas de migration Lua.

`active-brightness.py` choisit le connecteur focalisé à chaque invocation, redétecte le bus DDC par connecteur et regroupe les crans concurrents avec deux verrous dans XDG_RUNTIME_DIR. Lecture matérielle initiale, calcul borné, puis une écriture par lot. Minimum interne 1 %, externe 0 %. Les erreurs matérielles donnent une notification, sans modifier un autre écran.

44 tests Python passent, dont sélection de l’écran actif, limites et conservation des crans concurrents. `hyprctl configerrors` vide après rechargement. Détection matérielle réelle : HDMI-A-1 sur i2c-4 ; écran intégré eDP-1 exclu de DDC. À valider par Toubi : tourner la molette seule, cliquer, puis tourner avec Ctrl ; vérifier que Ctrl ne change pas aussi le son, et vérifier les touches du portable. La persistance i2c-dev après redémarrage reste distincte.

Sources : [notice R98Pro](https://manuals.plus/m/74d361820f508dd0536c05f122a908724e0ee49a5b8e21c0c4cfafa5ba269888_optim.pdf), [parseur Hyprland v0.56.2](https://github.com/hyprwm/Hyprland/blob/v0.56.2/src/config/legacy/ConfigManager.cpp).
