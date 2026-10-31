import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "scripts/WifiState.js" as WifiState
import "theme"
import "components"

// v18 — Flyout Wi-Fi autonome, jumeau de AudioFlyout.qml (même
// mécanique de positionnement/animation, voir les commentaires
// là-bas). Logique nmcli dupliquée depuis OverviewPage.qml — même
// duplication déjà acceptée dans ce projet pour ConnectionsPage vs le
// popup Wi-Fi du CC (voir HANDOFF v16).
//
// JAMAIS TESTÉ EN LIVE.
Window {
    id: flyout
    title: "Nord Violet Wifi Flyout"
    visible: false
    color: "transparent"
    width: 420
    height: Math.min(contentCol.implicitHeight + Theme.spacingLG * 2, 520)
    Process { id: networkSettings; command: ["qs", "-c", "nord-violet-cc", "ipc", "call", "settings", "page", "connections"] }

    Item {
        id: focusItem
        anchors.fill: parent
        Keys.onEscapePressed: flyout.hideFlyout()
        focus: true

        Rectangle {
            id: card
            anchors.fill: parent
            radius: 8
            color: "#0b0c10"
            border.width: 1
            border.color: Theme.accent
            clip: true

            // Même fondu que le CC ; masquage immédiat avant tout déplacement.
            opacity: flyout._revealed ? 1 : 0
            Behavior on opacity {
                enabled: flyout._revealed
                NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
            }

            Flickable {
                id: flick
                anchors.fill: parent
                anchors.margins: Theme.spacingLG
                clip: true
                contentWidth: width
                contentHeight: contentCol.implicitHeight
                boundsBehavior: Flickable.StopAtBounds
                // v24 : scrollbar visible ajoutée — le Flickable marchait
                // déjà (scroll molette fonctionnel) mais rien ne montrait
                // que c'était possible, d'où "on ne peut pas scroll" côté
                // retour utilisateur alors que la mécanique existait.
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                ColumnLayout {
                    id: contentCol
                    width: flick.width
                    spacing: Theme.spacingMD

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacingSM

                        Rectangle {
                            visible: false
                            implicitWidth: 26
                            implicitHeight: 26
                            radius: Theme.radiusSmall
                            color: Theme.accentMuted
                            border.width: 1
                            border.color: Theme.accent
                            Icon {
                                anchors.centerIn: parent
                                name: "wifi"
                                color: Theme.accent
                                implicitWidth: 14
                                implicitHeight: 14
                            }
                        }
                        Text {
                            text: "NV / NETWORK"
                            color: Theme.accent
                            font.family: "JetBrains Mono"
                            font.pixelSize: 11
                            font.letterSpacing: 1
                            font.bold: true
                            Layout.fillWidth: true
                        }
                        Toggle {
                            checked: root.wifiEnabled
                            onToggled: (state) => root.setWifiEnabled(state)
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: Theme.spacingSM

                        Text {
                            text: "[ RÉSEAUX DISPONIBLES ]"
                            font.family: "JetBrains Mono"
                            color: Theme.textMuted
                            font.pixelSize: 9
                            font.letterSpacing: 1
                            font.bold: true
                            Layout.fillWidth: true
                        }
                        Text {
                            text: root.wifiScanning ? "SCAN…" : "[ SCANNER ]"
                            font.family: "JetBrains Mono"
                            color: Theme.accent
                            font.pixelSize: 13
                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -6
                                enabled: root.wifiEnabled && !root.wifiScanning
                                onClicked: root.wifiRescan()
                            }
                        }
                    }

                    Text {
                        visible: !root.wifiEnabled
                        text: "Wi-Fi désactivé"
                        font.family: "JetBrains Mono"
                        color: Theme.textMuted
                        font.pixelSize: Theme.fontLabel
                    }

                    Text {
                        visible: root.wifiEnabled && root.wifiNetworks.length === 0
                        text: root.wifiScanning ? "Scan en cours…" : "Aucun réseau détecté."
                        font.family: "JetBrains Mono"
                        color: Theme.textMuted
                        font.pixelSize: Theme.fontLabel
                    }

                    Repeater {
                        model: root.wifiEnabled ? root.wifiNetworks : []

                        delegate: ColumnLayout {
                            id: netRow
                            Layout.fillWidth: true
                            spacing: 6

                            readonly property int netSignal: modelData.signal
                            readonly property bool netActive: modelData.active
                            readonly property string netSsid: modelData.ssid
                            readonly property string netSecurity: modelData.security

                            Rectangle {
                                Layout.fillWidth: true
                                implicitHeight: 54
                                radius: 2
                                color: netRow.netActive ? Theme.accentMuted : (netRowHover.hovered ? Theme.surfaceHover : "transparent")
                                border.width: 1
                                border.color: netRow.netActive ? Theme.accent : Theme.border

                                Behavior on color { ColorAnimation { duration: Theme.durationFast } }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    spacing: 8

                                    Text {
                                        text: netRow.netActive ? ">" : "·"
                                        font.family: "JetBrains Mono"
                                        font.pixelSize: 14
                                        color: netRow.netActive ? Theme.accent : Theme.textMuted
                                    }
                                    Text {
                                        text: netRow.netSsid
                                        font.family: "JetBrains Mono"
                                        color: netRow.netActive ? Theme.textPrimary : Theme.textSecondary
                                        font.pixelSize: Theme.fontBody
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                    }

                                    Row {
                                        visible: false
                                        spacing: 2
                                        Layout.alignment: Qt.AlignVCenter
                                        Repeater {
                                            model: 4
                                            delegate: Rectangle {
                                                width: 3
                                                height: 4 + index * 3
                                                anchors.bottom: parent ? parent.bottom : undefined
                                                radius: 1
                                                color: (index + 1) <= Math.ceil((netRow.netSignal / 100) * 4)
                                                    ? Theme.accent : Theme.border
                                            }
                                        }
                                    }

                                    Text {
                                        text: (netRow.netActive ? "ACTIF · " : "") + netRow.netSignal + "%"
                                        font.family: "JetBrains Mono"
                                        color: Theme.accent
                                        font.pixelSize: Theme.fontLabel
                                    }
                                }

                                HoverHandler { id: netRowHover }
                                TapHandler {
                                    onTapped: {
                                        if (netRow.netActive) return
                                        if (netRow.netSecurity === "--") {
                                            root.connectWifi(netRow.netSsid, netRow.netSecurity, "")
                                        } else {
                                            root.toggleWifiExpand(netRow.netSsid)
                                        }
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.leftMargin: 10
                                visible: root.wifiExpandedSsid === netRow.netSsid
                                spacing: 8

                                TextField {
                                    id: pwField
                                    Layout.fillWidth: true
                                    echoMode: TextInput.Password
                                    placeholderText: "Mot de passe"
                                    font.family: "JetBrains Mono"
                                    onAccepted: {
                                        root.connectWifi(netRow.netSsid, netRow.netSecurity, text)
                                        root.wifiExpandedSsid = ""
                                    }
                                    color: Theme.textPrimary
                                    font.pixelSize: Theme.fontBody
                                    background: Rectangle { color: Theme.background; radius: Theme.radiusSmall; border.width: 1; border.color: Theme.border }
                                    onTextChanged: root.wifiPwDraft = text
                                }

                                Rectangle {
                                    width: 90
                                    height: 30
                                    radius: 2
                                    color: Theme.accentMuted
                                    border.width: 1
                                    border.color: Theme.accent
                                    Text {
                                        anchors.centerIn: parent
                                        text: "Connecter"
                                        font.family: "JetBrains Mono"
                                        color: Theme.accent
                                        font.pixelSize: Theme.fontLabel
                                        font.bold: true
                                    }
                                    TapHandler {
                                        onTapped: {
                                            root.connectWifi(netRow.netSsid, netRow.netSecurity, pwField.text)
                                            root.wifiExpandedSsid = ""
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Text {
                        visible: root.wifiStatusText.length > 0
                        text: root.wifiStatusText
                        font.family: "JetBrains Mono"
                        color: Theme.accent
                        font.pixelSize: Theme.fontLabel
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                    Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Theme.border }
                    RowButton {
                        label: "Réglages réseau"
                        value: "[ OUVRIR ]"
                        showDivider: false
                        onClicked: { networkSettings.running = true; flyout.hideFlyout() }
                    }
                    RowButton {
                        label: "Fermer le panneau"
                        value: "[ ESC ]"
                        showDivider: false
                        onClicked: flyout.hideFlyout()
                    }
                }
            }
        }

        // v35 — nichée ici (dans focusItem, un vrai Item), pas au niveau
        // Window plus bas dans le fichier — un PointerHandler ne peut
        // pas être enfant direct d'un `Window`. Trouvé en relisant après
        // coup, jamais testé avant correction.
        // v41 — même fix que AudioFlyout.qml : la fermeture sur survol
        // perdu ne se déclenche que si le flyout a déjà été survolé au
        // moins une fois depuis son ouverture — sinon, depuis v40 (plus
        // sous le curseur à l'ouverture), il se refermait quasi
        // instantanément à chaque fois.
    }

    // -- État + logique Wi-Fi, dupliqués depuis OverviewPage.qml -----------
    QtObject {
        id: root
        property bool wifiEnabled: true
        property bool wifiScanning: false
        property var wifiNetworks: []
        property string wifiExpandedSsid: ""
        property string wifiPwDraft: ""
        property string wifiStatusText: ""

        function wifiRescan() {
            wifiScanning = true
            wifiRescanProc.running = true
        }

        function toggleWifiExpand(ssid) {
            wifiExpandedSsid = (wifiExpandedSsid === ssid) ? "" : ssid
            wifiPwDraft = ""
        }

        function connectWifi(ssid, security, password) {
            wifiStatusText = "Connexion à " + ssid + "…"
            var cmd = ["nmcli", "device", "wifi", "connect", ssid]
            if (security !== "--" && password.length > 0) {
                cmd.push("password")
                cmd.push(password)
            }
            wifiConnectProc.command = cmd
            wifiConnectProc.running = true
        }

        function setWifiEnabled(on) {
            wifiEnabled = on
            wifiToggleProc.command = ["nmcli", "radio", "wifi", on ? "on" : "off"]
            wifiToggleProc.running = true
        }
    }

    Process {
        id: wifiRadioRead
        command: ["nmcli", "-t", "-f", "WIFI", "radio"]
        stdout: StdioCollector { onStreamFinished: root.wifiEnabled = text.trim().toLowerCase() === "enabled" }
    }
    Process {
        id: wifiToggleProc
        onExited: wifiRadioRead.running = true
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
            wifiListRead.running = true
        }
    }
    Process {
        id: wifiListRead
        command: ["nmcli", "-t", "-f", "active,ssid,signal,security", "device", "wifi", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = text.trim().split("\n")
                var rows = []
                for (var i = 0; i < lines.length; i++) {
                    if (lines[i].length === 0) continue
                    var f = splitNmcli(lines[i])
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
                wifiListRead.running = true
            }
        }
        stderr: StdioCollector {
            onStreamFinished: if (text.trim().length > 0) root.wifiStatusText = "Échec : " + text.trim().split("\n")[0]
        }
    }

    // Identique à OverviewPage.qml::splitNmcli — nmcli échappe les ":"
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

    // -- Positionnement + animation (identique à AudioFlyout.qml) ----------
    // v47 — confirmer la taille et la position réelles, puis révéler.
    // no_anim côté Hyprland évite le déplacement animé sous le fondu QML.
    Process {
        id: moveProc
        stderr: StdioCollector {
            onStreamFinished: if (text.trim()) console.warn("[flyout] position:", text.trim())
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0 || !flyout._wantOpen) {
                flyout._positioning = false
                return
            }
            flyout._mapped = true
            if (flyout._geometryDirty) {
                monitorsProc.running = true
                return
            }
            flyout._positioning = false
            if (!flyout._revealed) flyout.reveal()
        }
    }

    // v40 — même changement que AudioFlyout.qml : moniteur FOCUS au lieu
    // du point de clic (demande explicite, même comportement que le
    // CC) — voir les commentaires détaillés là-bas.
    Process {
        id: monitorsProc
        command: ["hyprctl", "monitors", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                var mons
                try { mons = JSON.parse(text) } catch (e) { console.log("[wifi-flyout] JSON monitors invalide:", e); flyout._positioning = false; return }
                var mon = null
                for (var i = 0; i < mons.length; i++) {
                    if (mons[i].focused) { mon = mons[i]; break }
                }
                if (!mon && mons.length > 0) mon = mons[0]
                if (!mon) { console.log("[wifi-flyout] aucun moniteur focus trouvé"); flyout._positioning = false; return }

                flyout._geometryDirty = false
                moveProc.command = ["python3", "/home/toubi/.config/quickshell/nord-violet-cc/scripts/flyout-workspace.py", "position", "nvwifi", String(flyout.width), String(flyout.height), mon.name]
                moveProc.running = true
            }
        }
    }

    Process {
        id: clientsProc
        command: ["hyprctl", "clients", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                var clients
                try { clients = JSON.parse(text) } catch (e) { console.log("[wifi-flyout] JSON clients invalide:", e); return }
                var found = null
                for (var i = 0; i < clients.length; i++) if (clients[i].title === "Nord Violet Wifi Flyout") { found = clients[i]; break }
                if (!found) { console.log("[wifi-flyout] fenêtre pas encore mappée"); positionRetry.start(); return }
                monitorsProc.running = true
            }
        }
    }

    Timer { id: positionRetry; interval: 40; onTriggered: clientsProc.running = true }

    property bool _revealed: false
    property bool _positioning: false
    property bool _mapped: false

    // Recaler la taille réelle lorsque les données asynchrones changent
    // la hauteur. Pendant l'ouverture, attendre le dernier placement.
    property bool _wantOpen: false
    property bool _geometryDirty: false
    onHeightChanged: {
        if (visible && _wantOpen && (_mapped || _positioning)) {
            _geometryDirty = true
            geometryRefresh.restart()
        }
    }
    Timer {
        id: geometryRefresh
        interval: 40
        onTriggered: {
            if (flyout._wantOpen && flyout._geometryDirty && !flyout._positioning && flyout.visible) {
                flyout._positioning = true
                monitorsProc.running = true
            }
        }
    }


    Process {
        id: toggleSpecialProc
        command: ["python3", "/home/toubi/.config/quickshell/nord-violet-cc/scripts/flyout-workspace.py", "show", "nvwifi"]
        stderr: StdioCollector { onStreamFinished: if (text.trim().length > 0) console.log("[wifi-flyout] togglespecial stderr:", text.trim()) }
    }

    function reveal() {
        console.log("[wifi-flyout] reveal() appelé")

        toggleSpecialProc.command = ["python3", "/home/toubi/.config/quickshell/nord-violet-cc/scripts/flyout-workspace.py", "show", "nvwifi"]
        toggleSpecialProc.running = true
        _revealed = true
    }

    function hideFlyout() {
        console.log("[wifi-flyout] hideFlyout() appelé — _revealed:", _revealed)
        _wantOpen = false
        geometryRefresh.stop()
        if (!_revealed) return
        toggleSpecialProc.command = ["python3", "/home/toubi/.config/quickshell/nord-violet-cc/scripts/flyout-workspace.py", "hide", "nvwifi"]
        toggleSpecialProc.running = true
        _revealed = false
    }


    // v35 — même fix que AudioFlyout.qml : fermeture aussi au survol
    // perdu, pas seulement à la perte de focus. Le HoverHandler
    // lui-même est déclaré plus haut, DANS `focusItem` (un Item) — pas
    // ici, `Window` n'accepte pas un PointerHandler comme enfant direct.


    property real _clickX: 0
    property real _clickY: 0

    function show(x, y) {
        console.log("[wifi-flyout] show() — _mapped:", _mapped, "_revealed:", _revealed, "_positioning:", _positioning, "visible:", visible, "click:", x, y)
        _clickX = x
        _clickY = y
        wifiRadioRead.running = true
        root.wifiRescan()
        visible = true

        // v38 — même garde-fou anti-course que AudioFlyout.qml : 2
        // clics très rapprochés ne relancent pas 2 chaînes de
        // repositionnement en parallèle. `_clickX`/`_clickY` sont lues
        // en direct par le callback déjà en vol, pas de perte.
        if (_positioning) return

        _wantOpen = true
        _positioning = true
        _revealed = false

        if (!_mapped) {
            // v29 : forceActiveFocus() retiré, même raisonnement que
            // AudioFlyout.qml.
            clientsProc.running = true
        } else {
            monitorsProc.running = true
        }
    }
}
