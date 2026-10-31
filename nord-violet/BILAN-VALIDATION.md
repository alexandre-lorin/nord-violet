# Bilan Hyprland — 2 octobre 2026

## Terminé dans cette passe

Retouche esthétique supplémentaire : marges de contenu 20 px, navigation
224 px, inter-sections sans cumul de marges, titres plus lisibles, description
compacte, indicateur de défilement, toggle avancé rectiligne. Vue générale :
valeurs et contrôles ancrés sur le même bord droit, sans colonnes flottantes.
Captures Son et Vue générale revérifiées après ces ajustements.

- Ouverture Réglages avec activation de fenêtre ; navigation séparée de
  l'ouverture. Ne pas appeler `show()`/`showNormal()` à chaque changement
  de page : cela faisait alterner la taille entre normale et agrandie.
- Navigation Son → Écrans → Fonds → Bureau vérifiée : une fenêtre unique,
  1180 × 760 sur les quatre pages, après la correction.
- Son : liste réelle des sorties/entrées, volume/mute, lecture commune,
  événements audio, regroupement des écritures et relecture de secours.
- Écrans : en-tête compact monospace, fréquences existantes conservées,
  luminosité interne réelle avec relecture périodique (1,5 s).
- Bureau : suppression du hero serif et de la miniature décorative,
  états monospace et sections verticales.
- Fonds : galerie conservée, surfaces/boutons monospace plus droits ;
  options futures sans action retirées de l'interface.
- CC : taille constatée 620 × 320 ; S ouvre Vue générale ; Échap ferme
  le panneau si aucun sélecteur n'est ouvert. Écritures volume regroupées,
  relecture après écriture et événements de changement de sortie suivis.
- `clock` disponible dans ~/.local/bin : appelle exactement `chrono clock`.
  Présentation verticale inchangée, aucune modification de chrono.py.

## Vérifié

- Captures locales Son, Écrans, Fonds et Bureau inspectées.
- Données audio lues : quatre sorties, trois microphones, noms lisibles.
- Luminosité lue sur `nvidia_0` ; OSD luminosité déclenché sans modifier
  le matériel (test d'affichage uniquement).
- CC : raccourcis S et Échap exercés en session réelle.
- Une seule instance Quickshell après arrêt puis démarrage propre.
- QML des fichiers touchés validé ; 27 tests Python et 9 tests calendrier.
- `clock --help` et syntaxe du lanceur validés.

## À valider avec Toubi

- Esthétique et densité des quatre pages par rapport à la maquette A.
- Glisser rapidement les curseurs audio/micro/luminosité, puis modifier
  depuis Waybar/pavucontrol et observer les menus : les mécanismes sont
  présents, mais aucun changement réel de volume/mute n'a été imposé
  pendant cette passe. Ne pas confondre lecture des données et test
  complet aller-retour de tous les contrôles.
- Sélection de sortie/micro, import/application de fond et changement
  de fréquence : commandes conservées, pas exercées sur le bureau.
- Focus, profils, Wi-Fi et DND : pas de bascule réelle pendant la revue.

## Restant hors de cette passe

- Passe du 3 octobre : Profils, Omni, Notifications, Connexions,
  Raccourcis, Système et Hyprland harmonisés (espacement 8 px,
  en-têtes réduits, suppression des titres serif, contours droits).
  Sept pages ouvertes à 1180×760 et captures inspectées ; description
  des profils non tronquée et version Hyprland abrégée après revue.
  Validation esthétique utilisateur et tests des actions réelles restent
  nécessaires ; ni bascule Wi-Fi, ni changement de profil imposés.
- Décharge batterie après extinction : cause non établie, comparer une
  extinction directe depuis le terminal au menu sans modifier le BIOS.
- Vérifier `[Long_Life]` après un redémarrage : service préparé et mode
  réactivé par Toubi ; persistance après redémarrage à confirmer.
- Le crash Qt lié aux anciens Shortcut a un contournement clavier, pas
  une correction interne de Qt.

Nothing Link reste volontairement hors périmètre.
