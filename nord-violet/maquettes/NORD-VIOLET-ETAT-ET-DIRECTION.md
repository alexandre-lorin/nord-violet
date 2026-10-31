# Nord Violet — état réel et direction produit

Audit du 25 septembre 2026. Ce document sépare strictement ce qui fonctionne
aujourd’hui de ce qui est seulement prévu.

## Ce que Nord Violet possède réellement

### Shell et intégration Hyprland

- configuration Hyprland découpée par domaine et chargée par `source` ;
- deux groupes de cinq workspaces, répartis entre HDMI-A-1 et eDP-1 ;
- navigation, déplacement et redimensionnement des fenêtres au clavier ;
- déplacement et redimensionnement à la souris ;
- bascule flottante avec taille et recentrage automatiques ;
- scratchpads Discord, terminal, monitoring btop à 100 ms et Falcon ;
- capture région, plein écran et moniteur avec Swappy ;
- verrouillage Hyprlock, menu de session Wlogout et commande d’idle ;
- launcher Fuzzel et recherche unifiée Omni ;
- presse-papiers Cliphist ;
- touches multimédia avec OSD volume/luminosité ;
- emoji picker sur `Super+N`, fonctionnel mais visuellement rejeté.

### Control Center

- panneau contextuel placé sur le moniteur actif ;
- volume de sortie, choix de la sortie audio et suivi des changements PipeWire ;
- connexion active, débit montant/descendant et volet Wi-Fi ;
- activation Wi-Fi, scan, connexion et saisie du mot de passe ;
- Ne pas déranger via Mako ;
- état Bluetooth et périphérique connecté en lecture ;
- suppression des notifications ;
- flyouts audio et Wi-Fi indépendants ;
- animations d’ouverture, scrims et fermeture par Échap ;
- jeu d’icônes local et thème Nord Violet partagé ;
- accès aux Réglages depuis une rangée fixée en bas du panneau.

### Réglages actuels

- fenêtre 1280×820 avec rail latéral groupé ;
- recherche par page, navigation directe et mode Avancé ;
- huit pages : Apparence, Fonds, Écrans, Son, Connexions, Raccourcis, Système
  et Hyprland ;
- Apparence : choix d’accent réellement propagé, identité visuelle et aperçu ;
- Fonds : bibliothèque locale, miniatures, import, sélection aléatoire, choix
  tous les écrans ou écran précis, application persistante avec Hyprpaper ;
- Écrans : inventaire actif, résolution, fréquence, position et échelle ;
- Son : volume et choix de sortie ;
- Connexions : Wi-Fi, scan et connexion ;
- Raccourcis : lecture et présentation du vrai `keybinds.conf` ;
- Système : machine, kernel, uptime, RAM, disque et charge ;
- Hyprland : version et workspaces actifs.

### Habillage global

- palette Nord Violet commune à Hyprland, Waybar, Alacritty, GTK, Mako,
  Wlogout et Quickshell ;
- menu de session éditorial avec confirmation ;
- écran de verrouillage personnalisé ;
- fond et règles multi-écrans ;
- prototype HTML Atelier servant de référence visuelle.

## Ce qui n’existe pas encore

- éditeur graphique de moniteurs ;
- Bluetooth interactif ;
- entrées audio et volumes par application ;
- profils batterie, seuil de charge et veille depuis les Réglages ;
- édition des raccourcis et détection de conflits ;
- barre/dock/widgets configurables ;
- thèmes clair/sombre, typographie et densité réellement modifiables ;
- palette extraite automatiquement du fond ;
- rotation automatique des fonds ;
- règles de notifications par application ;
- règles de fenêtres Hyprland ;
- sauvegarde, diff, appliquer, annuler et restauration ;
- extensions/plugins ;
- recherche au niveau de chaque option.

## Enseignements des références externes

### Apple

- Une sidebar sert aux grandes zones, reste peu profonde et peut devenir
  escamotable quand la fenêtre rétrécit.
- Les actions critiques ne doivent pas vivre tout en bas de la sidebar : cette
  zone peut être masquée ou moins remarquée.
- Une seule action, exceptionnellement deux, doit être visuellement dominante
  dans une vue.
- Un bouton personnalisé doit avoir des états repos, survol, pression, attente
  et résultat ; une zone d’interaction généreuse compte davantage qu’un gros
  décor.
- La couleur sert à la hiérarchie et à l’état, pas à colorer toutes les actions.

Application à Nord Violet : garder le rail de gauche, retirer le gros portail
« Réglages » du bas du Control Center et éviter les petits badges décoratifs
autour des chevrons.

### GNOME

- Une vue doit avoir un sujet clair et une quantité de contenu digeste.
- Une hiérarchie ne devrait normalement avoir qu’un niveau de profondeur.
- Les vues doivent changer dans une même fenêtre plutôt que multiplier les
  fenêtres secondaires.

Application : Control Center pour les actions immédiates, Réglages pour la
configuration durable, sous-pages seulement lorsqu’un objet précis le demande.

### KDE

- « Simple par défaut, puissant quand nécessaire » correspond exactement au
  besoin de Nord Violet.
- Les actions sont contextuelles, les fonctions secondaires vont dans une
  sous-page ou un menu, et l’interface s’adapte à la largeur.
- Les icônes seules sont réservées aux actions universelles ; sinon le texte
  doit rester visible.
- Une ligne ne devrait avoir aucune ou une seule action inline, deux au maximum.
- La manipulation directe est préférable : glisser les modules d’une barre est
  meilleur que des boutons Monter/Descendre.

Application : un mode Avancé transversal, des éditeurs visuels pour écrans et
barre, et beaucoup moins de boutons permanents.

### Microsoft Fluent

- Un réglage simple doit se refléter immédiatement ; un bouton Appliquer ne se
  justifie que pour une opération risquée ou un lot cohérent.
- Toggle pour un booléen, options visibles pour deux à cinq choix, liste
  compacte au-delà.
- Une commande récurrente doit être proche de l’objet concerné.
- Les pages larges doivent conserver une largeur de lecture limitée.

Application : accent, volume, Wi-Fi et apparence appliqués en direct avec Undo ;
écrans, règles Hyprland et import validés explicitement avec aperçu du diff.

### Jakob Nielsen

- rendre l’état du système visible ;
- parler avec les mots de l’utilisateur ;
- favoriser la reconnaissance plutôt que la mémorisation ;
- prévenir les erreurs et fournir annulation/retour arrière ;
- rester cohérent et minimal.

Application : afficher « appliqué », « redémarrage nécessaire » ou « non pris en
charge » à côté du contrôle, et ne jamais présenter une fausse option.

### Linus Torvalds

Les préférences publiques de Linus ont varié entre KDE, GNOME et Xfce au fil des
années. Ce n’est donc pas une direction esthétique stable. Le signal constant
est fonctionnel : il critique les environnements qui retirent des contrôles
utiles au nom de la simplicité, notamment lorsque le comportement de la souris
ou des fenêtres ne peut plus être adapté à son workflow.

Leçon pour Nord Violet : fournir un excellent défaut, mais laisser les fonctions
essentielles modifiables. Le mode Avancé ne doit pas être un faux décor ; il doit
exposer les vrais mécanismes et valeurs actives.

## Direction visuelle recommandée

### Structure

- rail sombre et calme à gauche, inspiré de Ryoku ;
- contenu principal éditorial, plus aéré, inspiré de Caelestia ;
- aperçu contextuel à droite seulement pour Style, Fonds, Barre et Écrans ;
- rail réductible en icônes lorsque la fenêtre devient étroite ;
- profondeur maximale : catégorie → page → éventuelle fiche détaillée.

### Remplacement des boutons du bas

Les boutons actuels paraissent ajoutés après le contenu. La nouvelle règle doit
être : aucune barre de boutons globale permanente si aucune modification n’est
en attente.

- retour : bouton discret dans le header ou `Échap` ;
- Réglages depuis le Control Center : petite action « Ouvrir les réglages… »
  dans un menu `⋯`, plus `Super+S` comme accès principal ;
- action courante : directement dans la carte concernée ;
- modifications instantanées : toast compact avec « Annuler » ;
- modifications risquées : dock d’action flottant uniquement quand un brouillon
  existe, avec résumé `3 changements`, `Annuler` et une seule action violette
  `Appliquer` ;
- réinitialisation : menu secondaire de la page, jamais bouton dominant ;
- actions destructrices : zone dédiée, texte explicite et confirmation.

### Langage visuel

- violet réservé à la sélection, au focus et à l’action principale ;
- surfaces définies surtout par espace, contraste et traits fins ;
- trois rayons seulement : petit contrôle, carte, grande surface ;
- icônes cohérentes en trait, sans glyphes Unicode disparates ;
- titres courts, descriptions concrètes et valeurs actives visibles ;
- mouvement court pour le feedback, mouvement morphique plus ample uniquement
  pour ouvrir un panneau ou passer vers un aperçu ;
- moins de boîtes imbriquées : les groupes reposent d’abord sur l’espacement.

## Fonctions intelligentes à ajouter au workflow

### Priorité 1

1. **Palette de commandes unique** : applications, fichiers, actions système,
   réglages, emoji, clipboard, fenêtres et fonds dans Omni.
2. **Recherche universelle des réglages** : chaque résultat ouvre le bon
   contrôle et le met brièvement en évidence.
3. **Undo global** : toute action instantanée produit une possibilité d’annuler.
4. **Profils de contexte** : Travail, Nomade, Jeu et Nuit appliquent écrans,
   énergie, notifications, audio, fond et disposition.
5. **Limite batterie fiable** : état matériel réel, seuil appliqué et explication
   si le portable ne le supporte pas.
6. **Mode Focus** : DND, profil énergétique, applications et workspace dédiés en
   une action, avec minuterie visible.

### Priorité 2

7. Éditeur visuel d’écrans avec retour automatique si la nouvelle disposition
   n’est pas confirmée.
8. Barre composable par glisser-déposer avec aperçu direct.
9. Règles de notifications par application et résumé des notifications
   silencieuses.
10. Clipboard enrichi : favoris, images, recherche, OCR et exclusion des secrets.
11. Commandes contextuelles selon l’application active.
12. Historique des modifications de configuration avec restauration par section.

### Priorité 3

13. Génération de palette depuis le fond et templates réversibles pour les
   applications.
14. Widgets de bureau limités à ceux qui apportent une information réelle.
15. Extensions signées ou auditées après stabilisation du cœur.

## Décision proposée

La prochaine maquette doit porter sur une seule fenêtre Atelier comportant :

- rail Ryoku simplifié ;
- transitions et aperçu latéral inspirés de Caelestia ;
- pages `Style`, `Fonds`, `Bureau`, `Matériel`, `Système` et `Avancé` ;
- aucune rangée de boutons permanente en bas ;
- dock d’action flottant conditionnel ;
- emoji intégré à Omni plutôt qu’une application visuellement isolée.

Cette structure conserve l’identité Nord Violet tout en supprimant les éléments
qui donnent actuellement l’impression d’une maquette HTML transposée sans vraie
logique de produit.

## Sources de conception

- [Apple — Sidebars](https://developer.apple.com/design/human-interface-guidelines/sidebars)
- [Apple — Buttons](https://developer.apple.com/design/human-interface-guidelines/buttons)
- [GNOME — Navigation](https://developer.gnome.org/hig/guidelines/navigation.html)
- [KDE — Layout and navigation](https://develop.kde.org/hig/layout_and_nav/)
- [KDE — Simple by default](https://develop.kde.org/hig/simple_by_default/)
- [KDE — Icons](https://develop.kde.org/hig/icons/)
- [Microsoft — Guidelines for app settings](https://learn.microsoft.com/en-us/windows/apps/design/app-settings/guidelines-for-app-settings)
- [Microsoft — Commanding basics](https://learn.microsoft.com/en-us/windows/apps/design/basics/commanding-basics)
- [Nielsen Norman Group — 10 usability heuristics](https://www.nngroup.com/articles/ten-usability-heuristics/)
- [Entretien de 2009 avec Linus Torvalds, reproduit sur la liste Ubuntu](https://lists.ubuntu.com/archives/ubuntu-bd/2009-February/003321.html)
