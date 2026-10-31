# Battery protection

Diagnostics of 2 October 2026: BAT1 announces `Fast [Standard] Long_Life`.
The Game profile does not affect the load parameters: performance,
brightness, DND and VRR only. The newspaper of October 1 confirms a
claims extinction, but does not prove complete physical extinction.
The cause of the power-off discharge is not established.

The system service applies `Long_Life` at startup and verifies that the
firmware says `[Long_Life]`. It does not force a discharge until 80%.
It does not reapply the setting after waking up or resuming.
to zero firmware during the session. Its installation requires root.

## Installation from the terminal of Toubi

```sh
sudo install -m 644 /home/toubi/dotfiles/nord-violet/systemd/nord-violet-battery-protection.service /etc/systemd/system/nord-violet-battery-protection.service &&
sudo systemctl daemon-reload &&
sudo systemctl enable --now nord-violet-battery-protection.service
```

## Immediate verification, then after restart

```sh
systemctl status nord-violet-battery-protection.service --no-pager
cat /sys/class/power_supply/BAT1/charge_types
```

Expected: service `active (exited)` and `Fast Standard [Long_Life]`.
If the service fails, see:

```sh
journalctl -u nord-violet-battery-protection.service -b --no-pager
```

Do not confuse the charge limit with a discharge diagnosis after
extinction. This last phenomenon must still be measured separately.
