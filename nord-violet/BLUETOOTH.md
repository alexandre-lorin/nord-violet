# Bluetooth — 7 October 2026

## Update — 9 October 2026 (priority)

- Explicit search 20 seconds via bluetoothctl, list refreshed every 3 seconds.
- Distinction of detected/paired devices; Pair or Connect/Disconnect action.
- Forget a device with second click of confirmation; no automatic deletion.
- Dedicated BlueZ Gio agent via bluetooth-pair.py, registered only during requested pairing, without becoming agent by default. Zenity dialogs for PIN, digital code, code comparison and permissions; refusal of requests for another device, no automatic acceptance. Pairing does not automatically connect or mark the device Trusted.
- Gio and Zenity already installed, no dependencies added. The dialogs are not yet visually integrated in QML.
- Python/QML syntax, invalid address denial, 4 Node Bluetooth tests and 58 Python tests checked. These tests do NOT validate the agent's actual protocol with hardware; search/pairing/confirmation/refusal/connection/deletion remain to be tested by Toubi. No devices manipulated during checks.

API reference: https://github.com/bluez/bluez/blob/master/doc/org.bluez.Agent.rst

The notes below describe the old interface.

Settings → Connections page refined without additional dependencies.

- Controller reading, power and actual list of known devices.
- Separate reading of connections with `bluetoothctl devices Connected` (command confirmed in installed version).
- Connected device: Disconnect action; otherwise Connect. List grouped in a map, explicit empty state.
- Actions disabled during a command and when the controller is unavailable/turned off; no automatic activation of a device.
- Progress and failure messages kept separate from controller state. Detection of “Failed” even if bluetoothctl returns 0.
- Refresh visible every 5 seconds, without restarting already active processes.
- Pairing: existing bluetoothctl console, no new native dialog or pairing agent implemented this pass.

Validation: bluetooth service active, controller actually detected and Powered=yes; No connections, disconnects, or power toggles triggered during testing. qmllint without warning for ConnectionsPage.qml; 4 Node Bluetooth parsing tests, 47 Python tests and 9 calendar tests pass. Quickshell reloads the configuration without QML error (pre-existing portal warning).

User recipe: Settings → Connections; check the name and status of a known device; connect an already paired device then disconnect. Confirm the message and update the line. Do not test global cutoff if a Bluetooth input device is essential.
