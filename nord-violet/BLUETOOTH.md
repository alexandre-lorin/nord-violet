# Bluetooth — 7 octobre 2026

## Mise à jour — 9 octobre 2026 (prioritaire)

- Recherche explicite 20 secondes via bluetoothctl, liste rafraîchie toutes les 3 secondes.
- Distinction appareils détectés/appairés ; action Appairer ou Connecter/Déconnecter.
- Oublier un appareil avec second clic de confirmation ; aucune suppression automatique.
- Agent BlueZ Gio dédié via bluetooth-pair.py, enregistré uniquement pendant l'appairage demandé, sans devenir agent par défaut. Dialogues Zenity pour PIN, code numérique, comparaison de code et autorisations ; refus des demandes pour un autre appareil, aucune acceptation automatique. Appairage ne connecte pas automatiquement et ne marque pas l'appareil Trusted.
- Gio et Zenity déjà installés, aucune dépendance ajoutée. Les dialogues ne sont pas encore intégrés visuellement en QML.
- Syntaxe Python/QML, refus d'adresse invalide, 4 tests Node Bluetooth et 58 tests Python vérifiés. Ces tests ne valident PAS le protocole réel de l'agent avec du matériel ; recherche/appairage/confirmation/refus/connexion/suppression restent à tester par Toubi. Aucun appareil manipulé pendant les contrôles.

Référence API : https://github.com/bluez/bluez/blob/master/doc/org.bluez.Agent.rst

Les notes ci-dessous décrivent l'ancienne interface.

Page Réglages → Connexions affinée sans dépendance supplémentaire.

- Lecture du contrôleur, alimentation et liste réelle des appareils connus.
- Lecture séparée des connexions avec `bluetoothctl devices Connected` (commande confirmée dans la version installée).
- Appareil connecté : action Déconnecter ; sinon Connecter. Liste regroupée dans une carte, état vide explicite.
- Actions désactivées pendant une commande et lorsque le contrôleur est indisponible/éteint ; pas d'activation automatique d'un appareil.
- Messages de progression et d'échec conservés séparément de l'état du contrôleur. Détection de « Failed » même si bluetoothctl retourne 0.
- Actualisation visible toutes les 5 secondes, sans relancer les processus déjà actifs.
- Appairage : console bluetoothctl existante, pas de nouveau dialogue natif ni d'agent d'appairage implémenté cette passe.

Validation : service bluetooth actif, contrôleur réellement détecté et Powered=yes ; aucune connexion, déconnexion ou bascule d'alimentation déclenchée pendant les tests. qmllint sans avertissement pour ConnectionsPage.qml ; 4 tests Node de parsing Bluetooth, 47 tests Python et 9 tests calendrier passent. Quickshell recharge la configuration sans erreur QML (avertissement de portail préexistant).

Recette utilisateur : Réglages → Connexions ; vérifier le nom et l'état d'un appareil connu ; connecter un appareil déjà appairé puis déconnecter. Confirmer le message et la mise à jour de la ligne. Ne pas tester la coupure globale si un périphérique de saisie Bluetooth est indispensable.
