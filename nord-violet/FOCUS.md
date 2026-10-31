# Focus — 8 octobre 2026

## Utilisation

- CC : clic Focus démarre 50 minutes ; clic suivant met en pause, puis reprend. Clic droit arrête.
- Réglages → Profils : choisir 25 ou 50 minutes, pause/reprise et arrêt explicites.
- Waybar : compteur visible seulement pendant la session ou sa pause. Clic gauche pause/reprise, clic droit arrêt, clic molette ouvre Profils.
- Une pause fige le temps restant et restaure l'état DND initial. Reprendre active DND ; arrêter ou terminer restaure l'état initial.
- Notification à la fin, soumise au mode Mako restauré : si DND était déjà activé avant la session, elle peut rester silencieuse.

## Technique et validation

État compatible avec l'ancien format : `end_epoch previous_dnd`, échéance négative pour une pause. Verrou flock partagé ; workers libèrent le verrou pendant l'attente et ne terminent pas une session dont l'échéance a changé. Redémarrer une session conserve le DND initial. Le worker survit à la fermeture du CC ; il ne s'agit pas d'un service systemd persistant après redémarrage.

8 tests Focus avec Mako et notifications simulés ; 58 tests Python au total passent. QML et syntaxe Bash vérifiés. Aucune session réelle démarrée pour ne pas modifier les notifications de Toubi. Validation physique des clics et du rendu du compteur à faire.
