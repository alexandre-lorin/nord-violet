# Protection batterie

Diagnostic du 2 octobre 2026 : BAT1 annonce `Fast [Standard] Long_Life`.
Le profil Jeu ne touche pas aux paramètres de charge : performances,
luminosité, DND et VRR uniquement. Le journal du 1er octobre confirme une
demande d'extinction, mais ne prouve pas l'extinction physique complète.
La cause de la décharge hors tension n'est pas établie.

Le service système applique `Long_Life` au démarrage et vérifie que le
firmware indique `[Long_Life]`. Il ne force pas une décharge jusqu'à 80 %.
Il ne réapplique pas le réglage après une sortie de veille ou une remise
à zéro firmware pendant la session. Son installation nécessite root.

## Installation depuis le terminal de Toubi

```sh
sudo install -m 644 /home/toubi/dotfiles/nord-violet/systemd/nord-violet-battery-protection.service /etc/systemd/system/nord-violet-battery-protection.service &&
sudo systemctl daemon-reload &&
sudo systemctl enable --now nord-violet-battery-protection.service
```

## Vérification immédiate, puis après redémarrage

```sh
systemctl status nord-violet-battery-protection.service --no-pager
cat /sys/class/power_supply/BAT1/charge_types
```

Attendu : service `active (exited)` et `Fast Standard [Long_Life]`.
Si le service échoue, consulter :

```sh
journalctl -u nord-violet-battery-protection.service -b --no-pager
```

Ne pas confondre la limite de charge avec un diagnostic de décharge après
extinction. Il faut encore mesurer ce dernier phénomène séparément.
