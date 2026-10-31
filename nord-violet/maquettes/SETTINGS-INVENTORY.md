# Nord Violet — inventaire des réglages

Inventaire de conception pour la future application de réglages. Il compare
Nord Violet avec Ryoku Settings, Caelestia Nexus, Noctalia SettingsPanel et
DankMaterialShell. Une entrée listée ici est une possibilité de produit, pas
la confirmation qu'elle est déjà implémentée.

Références inspectées :

- <https://github.com/Ryoku-dev/ryoku>
- <https://github.com/caelestia-dots/shell>
- <https://github.com/NotWinder/noctalia-shell>
- <https://github.com/AvengeMedia/DankMaterialShell>

## Structure recommandée

### Accueil

- état global de la session et du shell ;
- CPU, mémoire, température, batterie et stockage ;
- mises à jour disponibles ;
- profil énergétique actif ;
- raccourcis vers les derniers réglages modifiés ;
- diagnostic rapide de la configuration ;
- import, export et restauration des réglages.

### Apparence

- thème sombre, clair ou automatique ;
- accent fixe ou extrait du fond d'écran ;
- variantes de palette : tonale, expressive, fidèle, neutre, monochrome ;
- couleurs des surfaces, textes, bordures et états ;
- intensité du contraste ;
- transparence et opacité ;
- flou, bruit, saturation et ombres ;
- rayon global des angles ;
- épaisseur et couleur des bordures ;
- police d'interface, police monospace et graisse ;
- échelle globale de l'interface ;
- densité compacte, normale ou confortable ;
- thème des icônes et du curseur ;
- aperçu en direct avant application ;
- propagation vers Waybar, terminal, GTK, Qt, notifications et écran de
  verrouillage.

### Fonds d'écran

- bibliothèque locale avec miniatures ;
- recherche, favoris et catégories ;
- import d'un fichier ou d'un dossier ;
- aperçu temporaire avant validation ;
- fond aléatoire ;
- diaporama au démarrage, périodique ou quotidien ;
- sélection depuis les favoris ou une catégorie ;
- intervalle de rotation ;
- transitions : fondu, glissement, croissance ou aléatoire ;
- ajustement : remplir, adapter, centrer ou étirer ;
- assombrissement du fond sous les widgets ;
- fonds animés ou vidéo, facultatifs ;
- même fond sur tous les écrans ou fond par écran ;
- synchronisation avec l'écran de verrouillage ;
- extraction automatique de palette ;
- choix clair/sombre et variante colorimétrique dérivés de l'image ;
- raccourci « fond suivant » et intégration au lanceur.

### Bureau et barre

- position, taille, marges et écran de la barre ;
- barre persistante ou masquage intelligent ;
- transparence, arrondis et couche Wayland ;
- composition par zones gauche, centre et droite ;
- ordre des modules par glisser-déposer ;
- espaces de travail, fenêtre active, applications ouvertes, média, horloge,
  météo, batterie, réseau, Bluetooth, audio, clavier, moniteurs système,
  mises à jour et tray ;
- options propres à chaque module ;
- formats de date et d'heure ;
- nombre et apparence des espaces de travail ;
- indicateurs d'application et icônes de fenêtres ;
- dock : position, taille, zoom, masquage et applications épinglées ;
- widgets de bureau : horloge, météo, calendrier, visualiseur et notes ;
- position et visibilité des widgets par écran ;
- comportement du Control Center, de l'OSD et des notifications.

### Animations

- activation globale et réduction des mouvements ;
- profil fluide, précis ou cinématique ;
- vitesse globale ;
- ouverture, fermeture et déplacement des fenêtres ;
- changement d'espace de travail ;
- panneaux, tiroirs et popups morphiques ;
- courbes et ressorts avancés ;
- flou animé et déformation, avec mode performance ;
- aperçu de chaque animation.

### Écrans

- représentation graphique et déplacement des moniteurs ;
- activation et écran principal ;
- résolution, fréquence, échelle et rotation ;
- duplication ou extension ;
- position et transformation ;
- VRR, HDR et profondeur de couleur si disponibles ;
- luminosité intégrée et DDC ;
- gamma et température de couleur ;
- lumière nocturne et programmation ;
- profil multi-écrans enregistré ;
- barre, widgets et fond d'écran configurables par moniteur.

### Son

- périphérique de sortie par défaut ;
- volume, mute et amplification maximale ;
- profils et ports de sortie ;
- périphérique d'entrée, gain et mute ;
- réduction du bruit ;
- volumes par application ;
- lecteur média préféré ;
- pas des touches de volume ;
- OSD audio ;
- sons d'interface optionnels.

### Connexions

- activation Wi-Fi et liste des réseaux ;
- connexion, oubli et modification d'un réseau ;
- réseau caché ;
- état Ethernet ;
- point d'accès ;
- VPN : ajout, connexion et suppression ;
- activation Bluetooth ;
- découverte, association et oubli d'appareils ;
- niveau de batterie des appareils compatibles ;
- mode avion.

### Entrées

- disposition, variante et modèle du clavier ;
- plusieurs dispositions et bascule ;
- délai et vitesse de répétition ;
- remappages courants ;
- sensibilité et accélération de la souris ;
- défilement naturel ;
- vitesse et profil du pavé tactile ;
- tap-to-click, clic secondaire et désactivation pendant la frappe ;
- gestes multi-doigts ;
- thème, taille, masquage et effets du curseur.

### Raccourcis

- liste complète issue de la configuration active ;
- recherche par action ou combinaison ;
- modification et suppression ;
- ajout de commandes personnalisées ;
- catégories : applications, fenêtres, espaces, système et capture ;
- détection des conflits ;
- retour aux valeurs par défaut ;
- aide visuelle ouvrable par raccourci.

### Énergie et session

- profil performance, équilibré ou économie ;
- état et santé de la batterie ;
- mode conservation Lenovo et seuils réellement supportés ;
- comportement différent sur secteur et batterie ;
- délai d'assombrissement, verrouillage, extinction et suspension ;
- comportement à la fermeture du capot ;
- inhibiteur de veille ;
- suspension pendant une lecture ou un enregistrement ;
- verrouillage et authentification ;
- avatar, horloge, notifications et média sur l'écran verrouillé ;
- menu de session et confirmations.

### Applications et services

- applications par défaut : terminal, navigateur, fichiers, éditeur et média ;
- applications au démarrage ;
- services utilisateur et état systemd ;
- notifications : position, durée, groupement et règles par application ;
- presse-papiers et historique ;
- capture d'écran et enregistrement vidéo ;
- qualité, codec, FPS, audio et dossier de sortie ;
- OCR, QR code et sélection de couleur ;
- météo, ville et unités ;
- langue, région, formats et fuseau horaire ;
- imprimantes et comptes utilisateur, à considérer seulement si fiables.

### Hyprland avancé

- disposition Dwindle ou Master ;
- gaps, bordures, arrondis, ombres, flou et opacité ;
- fenêtres flottantes, épinglées et pseudo-tiling ;
- règles de fenêtres et règles de calques ;
- espaces spéciaux ;
- plugins Hyprland ;
- variables d'environnement de session ;
- commandes de démarrage ;
- configuration par application ;
- rechargement avec validation et retour arrière ;
- affichage de la valeur réellement active.

### Maintenance et extensions

- version du shell et composants ;
- mises à jour avec notes de version ;
- diagnostic des dépendances ;
- journaux et erreurs récentes ;
- sauvegarde, export et import ;
- réinitialisation par section ;
- plugins et widgets additionnels ;
- vérification de compatibilité ;
- informations et crédits.

## Priorités pour Nord Violet

### V1 — nécessaire

- Apparence et aperçu en direct ;
- Fonds d'écran et palette dynamique ;
- Bureau et barre ;
- Écrans ;
- Son ;
- Connexions ;
- Entrées ;
- Raccourcis ;
- Énergie ;
- sauvegarde explicite, annulation et restauration.

### V2 — importante

- animations détaillées ;
- écran de verrouillage ;
- notifications et OSD ;
- applications par défaut et autostart ;
- règles Hyprland ;
- profils multi-écrans ;
- recherche globale avec synonymes.

### V3 — facultative

- extensions et widgets tiers ;
- fonds vidéo ;
- profils partageables ;
- imprimantes et utilisateurs ;
- éditeur complet des variables d'environnement.

## Garde-fous UX

- le Control Center reste réservé aux actions immédiates ;
- les Réglages ne lancent aucune commande privilégiée sans explication ;
- les options non supportées par la machine ne sont pas simulées ;
- toute modification risquée possède une validation et un retour arrière ;
- le mode Avancé cache la complexité sans cacher les fonctions courantes ;
- chaque recherche ouvre directement le réglage trouvé ;
- aucun réglage décoratif ne doit être présenté comme fonctionnel.
