import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Io
import "../scripts/WifiState.js" as WifiState
import "../theme"
import "../components"
import "../scripts/BluetoothState.js" as BluetoothState

// v32 — RÉELLE : mêmes commandes nmcli que WifiFlyout.qml, présentées
// en page de réglages complète (avec mot de passe + connexion, pas
// juste la liste). État propre à cette page, même duplication déjà
// acceptée ailleurs dans ce projet pour Wi-Fi (voir HANDOFF, v16).
ColumnLayout {
    id: root
    spacing: 8

    property bool wifiEnabled: false
    property bool wifiScanning: false
    property var wifiNetworks: []
    property string wifiExpandedSsid: ""
    property string wifiPwDraft: ""
    property string wifiStatusText: ""
    property bool bluetoothPowered: false
    property bool bluetoothAvailable: false
    property string bluetoothStatus: "Lecture du contrôleur…"
    property var bluetoothDevices: []
    property var bluetoothConnected: []
    property var bluetoothPaired: []
    property string forgetAddress: ""
    readonly property bool bluetoothBusy: bluetoothWrite.running || bluetoothPair.running
    property string bluetoothActionStatus: ""

    function refreshBluetooth() {
        if (!bluetoothRead.running) bluetoothRead.running = true
        if (!bluetoothList.running) bluetoothList.running = true
        if (!bluetoothConnections.running) bluetoothConnections.running = true
        if (!bluetoothPairedRead.running) bluetoothPairedRead.running = true
    }

    function writeBluetooth(args, message) {
        if (root.bluetoothBusy || !root.bluetoothAvailable) return
        root.bluetoothActionStatus = message
        bluetoothWrite.command = ["timeout", "12", "bluetoothctl"].concat(args)
        bluetoothWrite.running = true
    }

    function setWifiEnabled(on) {
        wifiEnabled = on
        wifiToggleProc.command = ["nmcli", "radio", "wifi", on ? "on" : "off"]
        wifiToggleProc.running = true
    }

    function wifiRescan() {
        wifiScanning = true
        wifiRescanProc.running = true
    }

    function connectWifi(ssid, security, password) {
        // v35 (relecture) : parité avec WifiFlyout.qml — un statut
        // "Connexion à…" immédiat, pas juste le succès/échec après coup.
        root.wifiStatusText = "Connexion à " + ssid + "…"
        var cmd = ["nmcli", "device", "wifi", "connect", ssid]
        if (security !== "--" && password.length > 0) {
            cmd.push("password")
            cmd.push(password)
        }
        wifiConnectProc.command = cmd
        wifiConnectProc.running = true
    }

    // Identique à WifiFlyout.qml::splitNmcli — nmcli échappe les ":"
    // internes avec "\", un simple split(":") casserait le parsing.
    function splitNmcli(line) {
        var out = []
        var cur = ""
        for (var i = 0; i < line.length; i++) {
            var c = line[i]
            if (c === "\\" && i + 1 < line.length) { cur += line[i + 1]; i++; continue }
            if (c === ":") { out.push(cur); cur = ""; continue }
            cur += c
        }
        out.push(cur)
        return out
    }

    Component.onCompleted: {
        wifiRadioReadProc.running = true
        wifiRescan()
    }

    Process {
        id: wifiRadioReadProc
        command: ["nmcli", "-t", "-f", "WIFI", "radio"]
        stdout: StdioCollector { onStreamFinished: root.wifiEnabled = text.trim().toLowerCase() === "enabled" }
    }
    Process {
        id: wifiToggleProc
        onExited: wifiRadioReadProc.running = true
    }
    Process {
        id: wifiRescanProc
        command: ["nmcli", "device", "wifi", "rescan"]
        onExited: wifiRescanSettle.start()
    }
    Timer {
        id: wifiRescanSettle
        interval: 1200
        onTriggered: {
            root.wifiScanning = false
            wifiListReadProc.running = true
        }
    }
    Process {
        id: wifiListReadProc
        command: ["nmcli", "-t", "-f", "active,ssid,signal,security", "device", "wifi", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = text.trim().split("\n")
                var rows = []
                for (var i = 0; i < lines.length; i++) {
                    if (lines[i].length === 0) continue
                    var f = root.splitNmcli(lines[i])
                    if (f.length < 4 || f[1].length === 0) continue
                    rows.push({ active: f[0] === "yes", ssid: f[1], signal: parseInt(f[2]) || 0, security: f[3] })
                }
                root.wifiNetworks = WifiState.networks(rows)
            }
        }
    }
    Process {
        id: wifiConnectProc
        stdout: StdioCollector {
            onStreamFinished: {
                root.wifiStatusText = ""
                wifiListReadProc.running = true
            }
        }
        stderr: StdioCollector {
            onStreamFinished: if (text.trim().length > 0) root.wifiStatusText = "Échec : " + text.trim().split("\n")[0]
        }
    }

    SectionHeader { text: "WI-FI"; first: true }
    SettingsCard {
        ToggleRow {
            label: "Wi-Fi"
            checked: root.wifiEnabled
            showDivider: false
            onToggled: (state) => root.setWifiEnabled(state)
        }
    }

    SectionHeader { text: "RÉSEAUX" }
    SettingsCard {
        Text {
            Layout.fillWidth: true
            Layout.margins: Theme.spacingMD
            visible: root.wifiEnabled && root.wifiNetworks.length === 0
            text: root.wifiScanning ? "Scan en cours…" : "Aucun réseau détecté."
            color: Theme.textMuted
            font.pixelSize: Theme.fontLabel
        }

        Text {
            Layout.fillWidth: true
            Layout.margins: Theme.spacingMD
            visible: !root.wifiEnabled
            text: "Wi-Fi désactivé"
            color: Theme.textMuted
            font.pixelSize: Theme.fontLabel
        }

        Repeater {
            model: root.wifiEnabled ? root.wifiNetworks : []

            delegate: ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                RowButton {
                    label: modelData.ssid
                    value: modelData.active ? "Connecté" : modelData.signal + "%"
                    showChevron: !modelData.active
                    showDivider: !(root.wifiExpandedSsid === modelData.ssid) &&
                                 index < root.wifiNetworks.length - 1
                    onClicked: {
                        if (modelData.active) return
                        if (modelData.security === "--") {
                            root.connectWifi(modelData.ssid, modelData.security, "")
                        } else {
                            root.wifiExpandedSsid = root.wifiExpandedSsid === modelData.ssid ? "" : modelData.ssid
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: Theme.spacingMD
                    Layout.rightMargin: Theme.spacingMD
                    Layout.bottomMargin: Theme.spacingSM
                    visible: root.wifiExpandedSsid === modelData.ssid
                    spacing: 8

                    TextField {
                        id: wifiPwField
                        Layout.fillWidth: true
                        echoMode: TextInput.Password
                        placeholderText: "Mot de passe"
                        color: Theme.textPrimary
                        font.pixelSize: Theme.fontBody
                        background: Rectangle { color: Theme.background; radius: Theme.radiusSmall; border.width: 1; border.color: Theme.border }
                        onTextChanged: root.wifiPwDraft = text
                    }

                    Rectangle {
                        width: 90
                        height: 30
                        radius: Theme.radiusSmall
                        color: Theme.accent
                        Text {
                            anchors.centerIn: parent
                            text: "Connecter"
                            color: Theme.background
                            font.pixelSize: Theme.fontLabel
                            font.bold: true
                        }
                        TapHandler {
                            onTapped: {
                                root.connectWifi(modelData.ssid, modelData.security, wifiPwField.text)
                                root.wifiExpandedSsid = ""
                            }
                        }
                    }
                }
            }
        }

        Text {
            Layout.fillWidth: true
            Layout.margins: Theme.spacingMD
            visible: root.wifiStatusText.length > 0
            text: root.wifiStatusText
            color: Theme.accent
            font.pixelSize: Theme.fontLabel
            wrapMode: Text.WordWrap
        }
    }

    SectionHeader { text: "BLUETOOTH" }
    SettingsCard {
        ToggleRow {
            label: "Bluetooth"
            subtext: root.bluetoothStatus
            checked: root.bluetoothPowered
            enabled: root.bluetoothAvailable && !root.bluetoothBusy
            onToggled: state => root.writeBluetooth(["power", state ? "on" : "off"], state ? "Activation…" : "Désactivation…")
        }
        RowButton {
            label: "Rechercher des appareils"
            subtext: "Mettez votre appareil en mode appairage"
            value: bluetoothScan.running ? "Recherche…" : "20 secondes"
            enabled: root.bluetoothPowered && !root.bluetoothBusy && !bluetoothScan.running
            showChevron: true
            showDivider: false
            onClicked: { root.bluetoothActionStatus = "Recherche pendant 20 secondes…"; bluetoothScan.running = true }
        }
    }

    SectionHeader { text: "APPAREILS / DÉTECTÉS ET APPAIRÉS" }
    SettingsCard {
        Repeater {
            model: root.bluetoothDevices
            delegate: ColumnLayout {
                Layout.fillWidth: true
                spacing: 0
                property bool connected: root.bluetoothConnected.indexOf(modelData.address) >= 0
                property bool paired: root.bluetoothPaired.indexOf(modelData.address) >= 0
                RowButton {
                label: modelData.name
                subtext: paired ? "Appareil appairé" : "Appareil détecté"
                value: connected ? "Déconnecter" : paired ? "Connecter" : "Appairer"
                enabled: root.bluetoothPowered && !root.bluetoothBusy
                showDivider: index < root.bluetoothDevices.length - 1
                onClicked: {
                    if (!paired) {
                        root.bluetoothActionStatus = "Appairage de " + modelData.name + "… Vérifiez les éventuels dialogues."
                        bluetoothPair.command = ["python3", "/home/toubi/.config/quickshell/nord-violet-cc/scripts/bluetooth-pair.py", modelData.address]
                        bluetoothPair.running = true
                    } else root.writeBluetooth([connected ? "disconnect" : "connect", modelData.address],
                        (connected ? "Déconnexion de " : "Connexion à ") + modelData.name + "…")
                }
                }
                RowButton {
                    visible: paired
                    label: root.forgetAddress === modelData.address ? "Confirmer la suppression" : "Oublier cet appareil"
                    value: root.forgetAddress === modelData.address ? "CONFIRMER" : "Supprimer l'appairage"
                    enabled: !root.bluetoothBusy
                    onClicked: {
                        if (root.forgetAddress !== modelData.address) { root.forgetAddress = modelData.address; return }
                        root.forgetAddress = ""
                        root.writeBluetooth(["remove", modelData.address], "Suppression de l'appairage…")
                    }
                }
            }
        }
        Text {
            Layout.fillWidth: true
            Layout.margins: Theme.spacingMD
            visible: root.bluetoothDevices.length === 0
            text: !root.bluetoothAvailable ? "Contrôleur indisponible" : !root.bluetoothPowered ? "Activez le Bluetooth pour gérer vos appareils." : "Aucun appareil détecté. Lancez une recherche après avoir activé le mode appairage de votre appareil."
            color: Theme.textMuted
            font.family: "JetBrains Mono"
            font.pixelSize: Theme.fontLabel
            wrapMode: Text.WordWrap
        }
    }
    Text {
        Layout.fillWidth: true
        visible: root.bluetoothActionStatus.length > 0
        text: root.bluetoothActionStatus
        color: Theme.accent
        font.family: "JetBrains Mono"
        font.pixelSize: Theme.fontLabel
        wrapMode: Text.WordWrap
    }
    Process {
        id: bluetoothConnections
        command: ["timeout", "5", "bluetoothctl", "devices", "Connected"]
        stdout: StdioCollector {
            onStreamFinished: root.bluetoothConnected = BluetoothState.connectedAddresses(text)
        }
        Component.onCompleted: running = true
    }
    Process {
        id: bluetoothRead
        command: ["timeout", "5", "bluetoothctl", "show"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.bluetoothAvailable = text.indexOf("Controller ") >= 0
                root.bluetoothPowered = /Powered:\s*yes/.test(text)
                root.bluetoothStatus = root.bluetoothAvailable ? (root.bluetoothPowered ? "Contrôleur actif" : "Contrôleur éteint") : "Contrôleur indisponible ou accès refusé"
            }
        }
        Component.onCompleted: running = true
    }
    Process {
        id: bluetoothList
        command: ["timeout", "5", "bluetoothctl", "devices"]
        stdout: StdioCollector { onStreamFinished: root.bluetoothDevices = BluetoothState.parseDevices(text) }
        Component.onCompleted: running = true
    }
    Process {
        id: bluetoothWrite
        stdout: StdioCollector { id: bluetoothResult }
        stderr: StdioCollector { id: bluetoothError }
        onExited: code => {
            var result = (bluetoothError.text + "\n" + bluetoothResult.text).trim()
            // bluetoothctl peut retourner 0 tout en affichant « Failed ».
            var failed = code !== 0 || /Failed|not available|not found|No default controller/i.test(result)
            root.bluetoothActionStatus = failed ? "Échec Bluetooth : " + (result.split("\n").filter(line => /Failed|not available|not found|No default controller/i.test(line))[0] || (code === 124 ? "délai dépassé" : "action refusée")) : "Action Bluetooth appliquée"
            root.refreshBluetooth()
        }
    }
    Process {
        id: bluetoothPairedRead
        command: ["timeout", "5", "bluetoothctl", "devices", "Paired"]
        stdout: StdioCollector { onStreamFinished: root.bluetoothPaired = BluetoothState.connectedAddresses(text) }
        Component.onCompleted: running = true
    }
    Process {
        id: bluetoothScan
        command: ["bluetoothctl", "--timeout", "20", "scan", "on"]
        onExited: code => { root.bluetoothActionStatus = code === 0 ? "Recherche terminée" : "Recherche interrompue ou indisponible"; root.refreshBluetooth() }
    }
    Process {
        id: bluetoothPair
        stdout: StdioCollector { id: pairResult }
        stderr: StdioCollector { id: pairError }
        onExited: code => {
            root.bluetoothActionStatus = code === 0 ? pairResult.text.trim() : pairError.text.trim() || "Appairage refusé"
            root.refreshBluetooth()
        }
    }
    Timer { interval: 3000; repeat: true; running: root.visible; onTriggered: if (!root.bluetoothBusy) root.refreshBluetooth() }
    Item { Layout.fillHeight: true }
}
