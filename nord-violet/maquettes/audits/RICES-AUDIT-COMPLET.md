# Audit complet des quatre shells de référence

Audit du 25 septembre 2026, réalisé depuis les sources locales importées. Les
inventaires générés associés contiennent les pages, réglages, services et
modules trouvés dans le code. Ce document distingue les fonctions visibles,
les moteurs techniques et les idées pertinentes pour Nord Violet.

## Dépôts audités

| Projet | Révision auditée | Nature réelle | Inventaire brut |
| --- | --- | --- | --- |
| Ryoku | `06091d4` | distribution Arch complète, Hub et shell QML, backends Go | [RYOKU-INVENTORY.md](generated/RYOKU-INVENTORY.md) |
| Caelestia Shell | `20e625d` | shell Quickshell/QML avec plugin C++ et Nexus | [CAELESTIA-INVENTORY.md](generated/CAELESTIA-INVENTORY.md) |
| Noctalia v5 | `f0339ef` | shell Wayland natif C++/OpenGL ES | [NOCTALIA-INVENTORY.md](generated/NOCTALIA-INVENTORY.md) |
| DankMaterialShell | `65dbb9f` | shell QML, backend Go et catalogue de 786 entrées | [DMS-INVENTORY.md](generated/DMS-INVENTORY.md) |

L’ancien `NotWinder/noctalia-shell` a été conservé localement comme version
legacy. Il n’est pas utilisé dans la comparaison : le Noctalia actuel est une
réécriture native et son périmètre a fortement grandi.

## Verdict rapide

| Besoin | Meilleure référence | Pourquoi |
| --- | --- | --- |
| Direction artistique et mouvement | Caelestia | surfaces morphing, transitions, hiérarchie visuelle forte |
| Réglages avancés de Hyprland | Ryoku | brouillon, aperçu, recherche, capacités du compositeur |
| Shell cohérent et architecture moderne | Noctalia v5 | surfaces, services, configuration et IPC unifiés |
| Couverture fonctionnelle maximale | DMS | réglages système, plugins, widgets et matériels spécialisés |
| Fonds, couleurs et thèmes d’applications | Noctalia + DMS | palettes, modèles, automatisation et cibles externes |
| Barre et widgets configurables | DMS | composition, instances et options par widget |

## 1. Ryoku

### Shell et surfaces

- barre modulaire avec rails, zones, panneaux, menus, média et HUD
  d’enregistrement ;
- dock avec applications, média, menus, épingles et masquage ;
- bureau avec widgets, calendrier, météo, statistiques, musique, paroles,
  visualiseur et menus contextuels ;
- launcher, notifications, verrouillage, capture de zone, caméra et affichage
  des frappes ;
- écran de bienvenue, aide aux raccourcis, épingle de contenu et outils de
  capture ;
- prise en charge Hyprland et Niri, changement de compositeur et abstraction
  des capacités disponibles.

### Hub de réglages

- Profil : matériel, état, statistiques et identité de la machine ;
- Général : langue, région, formats, fuseau, météo, police et échelle ;
- Mises à jour : canal, version, vérification et application ;
- Écrans : détection, disposition, résolution, fréquence, échelle, rotation et
  profils ;
- Connexions : Wi-Fi, Bluetooth et hotspot ;
- Entrées : layouts clavier, second layout, options XKB, remaps, souris,
  touchpad, accélération, défilement, gestes et curseur ;
- Graphismes et énergie : GPU AMD/NVIDIA, modes hybrides, passthrough VM,
  réglages CPU, profils, thermiques et limites de charge ;
- Animations : activation, vitesse, courbes et catégories ;
- Lockscreen : apparence, comportement, sécurité et thèmes ;
- Window Manager : layout, gaps, redimensionnement, snapping, bordures,
  arrondis, opacité, flou, ombres et comportement des fenêtres ;
- Plugins : catalogue Hyprland, installation, version, compatibilité et options
  dédiées ;
- règles de calques, règles de fenêtres et overrides par application ;
- Bar Studio : zones, ordre, widgets, style, dock et aperçu ;
- Bureau : fond, marque, visualiseur et placement ;
- Widgets : catalogue, ajout, placement et réglages ;
- Launcher : présentation, recherche et contenu ;
- Raccourcis : inventaire, édition, conflits et actions ;
- Session : autostart, commandes et variables d’environnement ;
- Enregistrement et capture : codec, fréquence, audio et destinations ;
- Dictée : moteur vocal, modèle et microphone ;
- Performance : profils, réduction d’effets et optimisation ;
- Fastfetch, import de configuration, add-ons, store et assistant IA Rashin.

### Moteurs annexes

- Ryogami : fonds locaux, Wallhaven, Wallpaper Engine/Steam Workshop,
  playlists, post-traitement, éclairage, Matugen et optimisation ;
- Palette Bridge : propagation vers applications et extensions ;
- Ryostore : extensions et widgets ;
- CLI, installateur ISO, paquets Arch, profils système et services systemd ;
- OpenRGB, QMK, éclairage, GPU, clipboard, import/annulation et publication de
  rice via backends Go.

### Ce qu’il faut reprendre

- recherche globale avec synonymes et liens directs ;
- mode simple/avancé ;
- brouillon, aperçu du diff, appliquer et valeurs d’usine ;
- masquage des options impossibles selon le matériel ou le compositeur ;
- Bar Studio à terme.

## 2. Caelestia Shell

### Shell et surfaces

- fond animé, horloge de bureau, visualiseur audio et image de fond ;
- barre avec workspaces, fenêtre active, horloge, statut, tray, alimentation et
  popouts contextuels ;
- dashboard avec média, paroles, météo, performances CPU/GPU/RAM/disque et
  raccourcis ;
- launcher avec applications, actions, calculatrice et recherche ;
- drawers, sidebar, utilitaires, toasts, notifications, OSD, session et lock ;
- sélecteur de zone et informations de fenêtre.

### Nexus

- Fond et style : bibliothèque, catégories, aperçu, mode clair/sombre, palette
  et variantes Material ;
- Applications : toutes les applications et fiche d’information ;
- Audio : sortie, entrée, mute et volume par application ;
- Bluetooth : activation, scan, association, connexion et fiche appareil ;
- Réseau : liste, mot de passe, réseaux enregistrés, ajout manuel, Ethernet et
  ajout VPN ;
- Langue et région ;
- Panneaux : dashboard, launcher, sidebar, barre/taskbar et utilitaires ;
- options détaillées de barre : workspaces, horloge, tray, fenêtre active et
  icônes d’état ;
- Services : notifications et comportements de fond ;
- À propos et informations système.

### Services et moteurs

- audio PipeWire, luminosité, couleurs dynamiques, mode jeu, inhibition idle,
  réseau nmcli, notifications, MPRIS, enregistrement, écrans, VPN, fonds,
  météo et temps ;
- collecteurs natifs pour CPU, GPU, mémoire, disques, réseau, capteurs, Cava,
  beat tracking et paroles ;
- introspection Hyprland, données d’applications, cache d’images et analyse des
  couleurs ;
- configuration globale structurée : général, apparence, fond, barre,
  dashboard, launcher, lock, Nexus, notifications, OSD, services, session,
  sidebar et utilitaires.

### Ce qu’il faut reprendre

- langage visuel des surfaces et transitions ;
- page Fonds comme expérience centrale, pas comme formulaire ;
- popouts contextuels et séparation nette entre usages quotidiens et réglages ;
- dashboard concis et visuel.

## 3. Noctalia v5

### Shell et surfaces

- barres multi-écrans, dock, launcher, overview, switcher de fenêtres, panneau
  de session et hot corners ;
- Control Center, clipboard avec images et favoris, notifications avec
  historique, OSD et tray ;
- fond d’écran, panneau de fonds, backdrop, widgets de bureau et éditeur de
  placement ;
- lockscreen, setup wizard, polkit, profils utilisateur et greeter séparé ;
- capture/annotation d’écran et indicateurs de confidentialité.

### Barre et widgets

- workspaces, taskbar, fenêtre active, launcher, Control Center et réglages ;
- horloge, météo, média, visualiseur audio, tray et texte personnalisé ;
- réseau, Bluetooth, volume, luminosité, batterie, profil énergétique et
  night light ;
- clipboard, notifications, caffeine, verrouillage clavier, layout clavier,
  confidentialité, capture et changement de thème ;
- boutons personnalisés, scripts et spacers ;
- placement gauche/centre/droite, comportement flottant, écrans ciblés et
  actions clic/molette configurables.

### Thèmes et fonds

- thèmes intégrés, communautaires ou générés depuis le fond ;
- modes clair, sombre et automatique, option OLED noir pur ;
- templates avec hooks d’application et d’annulation ;
- templates officiels pour Alacritty, Btop, Cava, Emacs, Foot, Ghostty, GTK,
  Helix, KDE, Kitty, Qt, Starship, WezTerm et plusieurs compositeurs ;
- fonds par dossiers clair/sombre, fill modes, couleurs de remplissage,
  transitions multiples, randomisation et changement périodique ;
- backdrop flou/teinté et lockscreen lié ou indépendant.

### Services système

- audio, batterie, luminosité, Bluetooth, réseau via NetworkManager/iwd/
  wpa_supplicant, modem, MPRIS, power-profiles, UPower et logind ;
- météo, localisation, calendrier vdir, night light et idle ;
- notifications DBus, tray StatusNotifier, PAM, polkit et comptes ;
- moniteur CPU, fréquence, charge, température, GPU/VRAM, RAM, réseau, disque et
  swap ;
- intégrations Hyprland, Niri, Sway, Scroll, Labwc, Mango, KDE, dwl, Triad et
  Umbriel ;
- configuration TOML hot-reload, overrides GUI, validation, migrations,
  export, IPC et hooks d’automatisation ;
- plugins pour widgets de barre, providers du launcher, panneaux, widgets de
  bureau, commandes et services.

### Ce qu’il faut reprendre

- architecture unifiée et frontières claires du shell ;
- launcher à providers, incluant directement les emoji ;
- thèmes applicatifs réversibles ;
- paramètres en fichier lisible avec hot reload et IPC ;
- plugins seulement après stabilisation du noyau.

## 4. DankMaterialShell

### Surfaces principales

- DankBar, Dock, DankDash, DankIsland et app drawer ;
- Control Center extensible, réseau détaillé et process list ;
- notifications, centre d’historique, OSD, power menu et verrouillage ;
- bureau, widgets, overlays de workspaces, notepad et color picker ;
- greeter greetd et panneau de réglages complet.

### Personnalisation

- source de palette, extraction Matugen, couleurs, surfaces, contrastes,
  transparence, rayons, bordures et arrière-plans ;
- mode clair/sombre programmé ;
- typographie, tailles, graisse, animations, durée, réduction du mouvement,
  ombres et sons ;
- fond local, fill, blur, tint, couleurs extraites, rotation automatique,
  dossier, ordre et intervalle ;
- propagation du thème vers Alacritty, Foot, Ghostty, Kitty, WezTerm, GTK,
  Qt, KColorScheme, Firefox/Zen, Vencord/Vesktop/Equibop, Neovim, Emacs,
  Fcitx5, Hyprland, Niri, MangoWC et autres.

### Barre, dock et widgets

- plusieurs barres et docks, choix d’écran, position, dimensions, flottement,
  marges, visibilité et autohide ;
- composition et réorganisation des zones ;
- options propres à launcher, workspaces, fenêtre active, applications,
  musique, horloge, batterie, moniteur système, clavier, confidentialité,
  Control Center, tray et mises à jour ;
- widgets de bureau intégrés : horloge et moniteur système ;
- instances de widgets, placement, style de texte, fond et intensité ;
- plugins ajoutant widgets, cartes dashboard, pages, providers launcher,
  panneaux attachés et daemons.

### Réglages système

- affichage graphique avec disposition des moniteurs, résolution, fréquence,
  échelle, rotation, miroir, ICC et identification ;
- audio, sortie/entrée et applications ;
- Wi-Fi, Ethernet, VPN, cellulaire et statut réseau ;
- Bluetooth ;
- batterie, seuils de charge, profils, veille et actions de capot ;
- souris, touchpad, clavier, layout et gamma/night mode ;
- imprimantes CUPS ;
- comptes, création d’utilisateur et avatars ;
- applications par défaut, autostart, applications ouvertes et règles de
  fenêtres ;
- raccourcis, configuration du compositeur et apparence des workspaces ;
- notifications, règles par application, DND et sons ;
- lockscreen, greeter, média, météo, localisation, locale et fuseau ;
- clipboard, palette injection, mises à jour système et gestion des plugins.

### Ce qu’il faut reprendre

- catalogue de réglages indexé ;
- composition des barres par instances ;
- display editor visuel ;
- règles de notifications ;
- limites de charge batterie visibles et vérifiables ;
- intégrations matérielles en modules optionnels.

## Matrice fonctionnelle consolidée

| Domaine | Ryoku | Caelestia | Noctalia v5 | DMS |
| --- | :---: | :---: | :---: | :---: |
| Barre multi-écrans | Oui | Oui | Oui | Oui |
| Barre composable par widgets | Avancé | Limité | Avancé | Très avancé |
| Dock | Oui | Non central | Oui | Oui |
| Launcher à providers | Oui | Oui | Oui | Oui |
| Emoji intégrés au launcher | Non central | Non central | Oui | Plugin/externe |
| Dashboard | Oui | Excellent | Control Center | Oui |
| Control Center | Panneaux | Popouts/Nexus | Oui | Oui, extensible |
| Notifications + historique | Oui | Oui | Oui | Oui |
| Règles de notifications | Limité | Limité | Filtres | Oui |
| Clipboard texte/image | Oui | Oui | Oui | Oui |
| Fonds : bibliothèque | Très avancé | Excellent | Avancé | Avancé |
| Fonds en ligne | Wallhaven/Steam | CLI | Plugins/API | Extensions |
| Rotation automatique | Oui | Oui | Oui | Oui |
| Palette depuis fond | Oui | Oui | Oui | Oui |
| Thèmes d’applications | Palette Bridge | CLI | Templates | Matugen très large |
| Mode clair/sombre planifié | Oui | Oui | Oui | Oui |
| Réglages Hyprland profonds | Excellent | Faibles | Non invasifs | Avancés |
| Éditeur visuel des écrans | Oui | Partiel | Hors périmètre | Excellent |
| Entrées clavier/souris | Oui | Minimal | Hors périmètre | Oui |
| Audio par application | Oui | Oui | Oui | Oui |
| Wi-Fi/Ethernet/VPN | Oui | Oui | Oui | Oui |
| Bluetooth et pairing | Oui | Oui | Oui | Oui |
| Batterie/profils/charge | Oui | Statut | Oui | Oui |
| Capture + annotation | Oui | Enregistrement | Oui | Capture |
| Lock PAM | Oui | Oui | Oui | Oui |
| Greeter | SDDM | Non | Projet séparé | Greetd |
| Widgets de bureau | Oui | Horloge/visuel | Oui | Oui |
| Plugins/extensions | Oui | Non central | Oui | Oui |
| Recherche globale des réglages | Excellente | Navigation | Oui | Excellente |
| Brouillon + appliquer | Oui | Direct | Overrides | Mixte |
| IPC/CLI | Oui | Oui | Très complet | Oui |
| Multi-compositeur | Hyprland/Niri | Hyprland | Très large | Large |

## Conséquence pour Nord Violet

La page actuelle « Apparence » paraît inutile parce qu’elle mélange des
réglages sans produire une expérience visible. Les quatre références séparent
clairement trois usages :

1. **Style** : palette, surfaces, typographie, mouvement et aperçu global ;
2. **Fonds** : bibliothèque, sélection, automatisation et génération de palette ;
3. **Bureau et fenêtres** : barre, dock, widgets, gaps, bordures et règles.

Nord Violet doit donc remplacer « Apparence » par ces trois entrées. La
prochaine implémentation recommandée est :

- intégrer l’emoji dans le launcher/outils avec une DA commune, au lieu d’une
  fenêtre autonome générique ;
- construire d’abord **Style** avec un vrai aperçu et peu de commandes ;
- conserver **Mon écran** pour le matériel et la disposition ;
- créer ensuite **Bureau** pour la barre, les widgets et le comportement ;
- reporter les options expertes Hyprland dans un mode Avancé recherchable.

## Limites de l’audit

- une entrée présente dans le code peut être expérimentale, conditionnelle ou
  dépendre d’un binaire externe ;
- l’inventaire DMS reprend volontairement les 786 entrées de son index, même si
  certaines sont des titres, sous-sections ou variantes conditionnelles ;
- les inventaires sont régénérables avec
  `maquettes/audits/generate-rice-inventories.sh` après mise à jour des clones.
