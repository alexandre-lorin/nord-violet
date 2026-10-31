# Volume à la molette — 6 octobre 2026

## État final : contrôle natif Waybar rétabli

Après nouveau retour de saccades, `custom/audio` est remplacé par `pulseaudio` natif dans les deux configurations. `scroll-step: 1`, `max-volume: 100`, aucune commande `on-scroll-up/down` : pas de lancement Python/wpctl ni de flux JSON supplémentaire pendant la molette. Clic gauche mute, clic molette flyout, clic droit pavucontrol conservés. Capture après rechargement : 53 % dans Waybar, 53 % sur la sortie par défaut, non muet. Une barre par écran. Le script `waybar-watch` demeure disponible mais n’est plus utilisé par Waybar. Le ressenti doit être validé par l’utilisateur.

Retouche après signalement de blocages : flux Waybar regroupé par rafales (maximum une lecture par 35 ms, dernière mise à jour conservée). Centre de contrôle et vue générale des settings : polling arrêté lorsqu’ils sont fermés ; notifications sink-input sans effet sur le volume global ignorées ; lectures audio du flyout regroupées et non concurrentes. 36 tests Python réussis, validation QML et rechargement réel du shell réussis. Pas de saturation mémoire constatée ; le lag global n’a pas été reproduit et ne peut pas être déclaré entièrement résolu sans retour utilisateur.

Le premier correctif plafonnait le volume avec trois appels pactl successifs sous verrou. Il provoquait une file d’attente lors du défilement rapide ; Waybar affichait l’état avec un intervalle d’une seconde.

La variation utilise désormais un seul appel `wpctl set-volume --limit 1.0 @DEFAULT_AUDIO_SINK@ 1%+` (ou `1%-`). Les mêmes commandes bornées servent aussi aux touches volume via le script audio commun.

Waybar utilise `audio-devices.py waybar-watch`, un flux JSON alimenté par `pactl subscribe`, sans polling d’une seconde. Mise à jour sur événements de sortie et changement de serveur ; états identiques filtrés ; processus abonné arrêté à la fermeture. `restart-interval: 1` permet à Waybar de relancer le flux si l’abonnement se coupe.

Validation : 34 tests Python réussis, sortie JSON du flux contrôlée sur le serveur audio réel, volume et mute conservés (test de variation nulle), une surface Waybar par écran après rechargement. Pas de test sonore ni de défilement manuel effectué à la place de l’utilisateur.
