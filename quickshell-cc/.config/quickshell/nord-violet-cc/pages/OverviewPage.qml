import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../scripts/WifiState.js" as WifiState
import "../theme"
import "../components"

// Page "Overview" — v2, sur retour utilisateur après premier test live :
//   1. Volume audio : barre -> slider draggable (drag = change le volume
//      pour de vrai, via pactl set-sink-volume)
//   2. "Pas instant synchro avec le vrai son" : le Timer 15s ne suffisait
//      pas quand le volume change ailleurs (raccourci clavier, autre
//      app). Ajout d'un `pactl subscribe` qui tourne en continu et
//      redéclenche la lecture audio dès qu'un événement sink arrive —
//      quasi-instantané au lieu d'attendre jusqu'à 15s.
//
// ATTENTION (nouveau pattern, jamais utilisé ailleurs dans ce projet) :
// `pactl subscribe` ne s'arrête jamais tout seul, donc on ne peut pas
// utiliser StdioCollector (qui attend la FIN du process). Utilise
// `SplitParser` à la place, qui lit ligne par ligne pendant que le
// process tourne — pattern standard Quickshell pour ce genre de flux,
// mais PAS ENCORE VÉRIFIÉ EN LIVE ici. Si l'appli plante ou que le
// volume ne bouge plus du tout au chargement, c'est le premier suspect :
// dis-le-moi et je repasse sur un Timer court (2-3s) en secours, moins
// élégant mais sans risque.
//
// STATUT PAR CARTE (rappel de la version précédente, toujours valable) :
//   - Audio, Network, Brightness, Memory, Battery : commandes standard.
//   - DND : suppose un mode mako nommé "dnd".
//   - Bluetooth : lecture seule.
//
// v3 (redesign "Control Center compact") : Night Light retiré de cette
// page — c'était un toggle purement cosmétique (aucun outil de température
// de couleur branché derrière), et un contrôle qui ne contrôle rien casse
// la confiance dans tout le reste. Groupe "Réglages rapides" (SettingRow)
// remplacé par 3 QuickTile (Ne pas déranger / Bluetooth / Notifications),
// groupe "Système" remplacé par un bandeau compact une-ligne. Hero Audio
// agrandi, Réseau réduit — voir QuickTile.qml pour le nouveau composant.
ColumnLayout {
    id: root
    spacing: Theme.spacingMD

    // -- État -----------------------------------------------------------
    property int audioPct: 0
    property string audioSink: ""
    property string audioSinkName: ""
    property bool audioPickerOpen: false
    property var audioSinks: []
    property string netName: ""
    property string netType: ""
    property string netDevice: ""
    property bool netConnected: false
    property real netRxRate: 0
    property real netTxRate: 0
    property real netPrevRx: -1
    property real netPrevTx: -1
    property bool dndOn: false
    property bool btPowered: false
    property string btDevice: ""
    property bool loaded: false
    property bool pollingActive: visible
    onPollingActiveChanged: if (pollingActive) { root.reload(); sinkNameRead.running = true }
    property string profileKey: "custom"
    property string profileName: "Personnalisé"
    property bool focusActive: false
    property bool focusPaused: false
    property int focusRemaining: 0

    // -- État : volet Wi-Fi (v16) ----------------------------------------
    // Même logique que ConnectionsPage.qml (nmcli), dupliquée ici
    // volontairement : ConnectionsPage vit dans SettingsWindow (fenêtre
    // séparée depuis v9), donc pas d'accès direct à son état depuis ce
    // popup sans les fusionner en un singleton partagé — hors scope de
    // cette demande. Duplication de logique nmcli, pas de duplication
    // de source de vérité côté système (les deux lisent/écrivent le
    // même NetworkManager).
    property bool wifiPickerOpen: false
    property bool wifiEnabled: true
    property bool wifiScanning: false
    property var wifiNetworks: []
    property string wifiExpandedSsid: ""
    property string wifiPwDraft: ""
    property string wifiStatusText: ""

    function reload() {
        audioRead.running = true
        netRead.running = true
        dndRead.running = true
        btPoweredRead.running = true
        btDeviceRead.running = true
        profileRead.running = true
        focusRead.running = true
    }

    function nextProfile() {
        var keys = ["work", "mobile", "game", "night"]
        var current = keys.indexOf(profileKey)
        var next = keys[(current + 1) % keys.length]
        profileApply.command = ["/home/toubi/.config/quickshell/nord-violet-cc/scripts/profilectl.sh", next]
        profileApply.running = true
    }

    function formatFocus(seconds) {
        return Math.floor(seconds / 60).toString().padStart(2, "0") + ":" + (seconds % 60).toString().padStart(2, "0")
    }

    function toggleFocus() {
        if (focusToggle.running) return
        focusToggle.command = ["/home/toubi/.config/quickshell/nord-violet-cc/scripts/focusctl.sh", (focusActive || focusPaused) ? "pause-toggle" : "start", "50"]
        focusToggle.running = true
    }

    // v16 : ouvrir un des deux popups (audio/wifi) ferme l'autre — un
    // seul volet visible à la fois, même popup overlay dans
    // ControlCenter.qml.
    function openAudioPicker() {
        wifiPickerOpen = false
        audioPickerOpen = true
        audioSinksRead.running = true
    }

    function closeAudioPicker() {
        audioPickerOpen = false
    }

    function openWifiPicker() {
        audioPickerOpen = false
        wifiPickerOpen = true
        wifiRadioRead.running = true
        root.wifiRescan()
    }

    function closeWifiPicker() {
        wifiPickerOpen = false
        wifiExpandedSsid = ""
        wifiPwDraft = ""
    }

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

    // Identique à ConnectionsPage.qml::splitNmcli — nmcli échappe les
    // ":" internes (ex. adresse MAC) avec "\", un simple split(":")
    // casserait le parsing. Dupliqué ici pour la même raison que le
    // reste du bloc Wi-Fi (2 fenêtres séparées, pas de state partagé).
    function splitNmcli(line) {
        var out = []
        var cur = ""
        for (var i = 0; i < line.length; i++) {
            var c = line[i]
            if (c === "\\" && i + 1 < line.length) {
                cur += line[i + 1]
                i++
                continue
            }
            if (c === ":") {
                out.push(cur)
                cur = ""
                continue
            }
            cur += c
        }
        out.push(cur)
        return out
    }

    function setVolume(pct) {
        pct = Math.max(0, Math.min(100, Math.round(pct)))
        audioPct = pct
        audioWriteDelay.restart()
    }

    function selectSink(name) {
        sinkSet.command = ["python3", "/home/toubi/.config/quickshell/nord-violet-cc/scripts/audio-devices.py", "select", name]
        sinkSet.running = true
        closeAudioPicker()
    }

    function formatRate(bytesPerSec) {
        if (bytesPerSec < 1024) return bytesPerSec.toFixed(0) + " o/s"
        if (bytesPerSec < 1024 * 1024) return (bytesPerSec / 1024).toFixed(0) + " Ko/s"
        return (bytesPerSec / (1024 * 1024)).toFixed(1) + " Mo/s"
    }

    // -- Hero : Audio (carte principale) + Réseau (secondaire) -----------
    // v3 (redesign "Control Center compact") : Audio devient la carte
    // dominante (2/3 de la largeur environ), Réseau passe en secondaire —
    // c'est la donnée qu'on regarde/ajuste le plus souvent depuis ce
    // panneau, elle mérite plus d'espace que les autres.
    // v14 : le popup de sélection de sortie n'est plus rendu ICI (il
    // vivait dans un panneau inline sous cette RowLayout) — il vit
    // maintenant dans ControlCenter.qml, au-dessus de TOUT le panneau
    // (demande explicite : "un popup stylé... par dessus des autres
    // trucs"). Cette page expose juste l'état (audioPickerOpen,
    // audioSinks, audioPct, audioSink, audioSinkName) + les fonctions
    // (openAudioPicker/closeAudioPicker/setVolume/selectSink) que
    // ControlCenter.qml lit/appelle via l'id `overviewPageItem`.
    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.spacingMD

        HeroStat {
            id: audioCard
            Layout.fillWidth: true
            Layout.preferredHeight: Math.max(audioCard.implicitHeight, networkCard.implicitHeight)
            label: "Sortie audio"
            value: root.audioPct + "%"
            sub: root.audioSink
            subClickable: true
            cardClickable: true
            progress: root.audioPct / 100
            interactive: true
            onProgressEdited: (v) => root.setVolume(v * 100)
            onSubTapped: root.openAudioPicker()
            onCardTapped: root.openAudioPicker()
        }

        HeroStat {
            id: networkCard
            Layout.preferredWidth: 170
            Layout.preferredHeight: Math.max(audioCard.implicitHeight, networkCard.implicitHeight)
            Layout.fillWidth: false
            label: "Réseau"
            icon: ""
            value: root.netConnected ? "Connecté" : "Déconnecté"
            sub: root.netConnected ? (root.netName + " · " + root.netType) : ""
            meta: root.netConnected && root.netPrevRx >= 0
                ? ("↓ " + root.formatRate(root.netRxRate) + " · ↑ " + root.formatRate(root.netTxRate))
                : ""
            tag: ""
            // v16 : toute la carte ouvre le volet Wi-Fi, même pattern que
            // la carte Audio (cardClickable, HeroStat.qml).
            cardClickable: true
            onCardTapped: root.openWifiPicker()
        }
    }

    // -- Contrôles rapides (tiles) -----------------------------------------
    // v3 : remplace le groupe SettingRow "Réglages rapides". 3 tiles
    // scannables d'un coup d'œil au lieu d'une liste administrative.
    // Night Light retiré : c'était un toggle purement cosmétique (aucun
    // outil de température de couleur identifié/branché chez l'utilisateur)
    // — règle du projet : si ça ne contrôle rien, ça ne s'affiche pas.
    ColumnLayout {
        Layout.fillWidth: true
        spacing: Theme.spacingSM

        Text {
            text: "CONTRÔLES RAPIDES"
            color: Theme.textMuted
            font.pixelSize: Theme.fontLabel
            font.family: "JetBrains Mono"
            font.letterSpacing: 1
            font.bold: true
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingSM

            QuickTile {
                label: "Ne pas déranger"
                icon: "dnd"
                value: root.dndOn ? "Actif" : "Inactif"
                active: root.dndOn
                interactive: true
                onTapped: {
                    var next = !root.dndOn
                    root.dndOn = next
                    dndSet.command = ["makoctl", "mode", next ? "-a" : "-r", "dnd"]
                    dndSet.running = true
                }
            }

            QuickTile {
                label: "Profil"
                icon: "profile"
                value: root.profileName
                active: root.profileKey !== "custom"
                interactive: true
                onTapped: root.nextProfile()
            }

            QuickTile {
                label: "Focus"
                icon: "focus"
                value: root.focusPaused ? "Pause · " + root.formatFocus(root.focusRemaining) : root.focusActive ? root.formatFocus(root.focusRemaining) : "50 min"
                active: root.focusActive
                interactive: true
                secondaryInteractive: root.focusActive || root.focusPaused
                onSecondaryTapped: {
                    if (focusToggle.running) return
                    focusToggle.command = ["/home/toubi/.config/quickshell/nord-violet-cc/scripts/focusctl.sh", "cancel"]
                    focusToggle.running = true
                }
                onTapped: root.toggleFocus()
            }

            QuickTile {
                label: "Notifications"
                icon: "bell"
                value: "Historique"
                interactive: true
                onTapped: notificationsOpen.running = true
            }
        }
    }

    // v14 : bandeau Système (Batterie/Mémoire/Luminosité) retiré —
    // demande explicite : batterie déjà visible dans waybar, RAM déjà
    // suivie via btop, jugé redondant. Ne pas le remettre sans qu'on
    // le redemande explicitement.

    Text {
        visible: !root.loaded
        text: "Chargement..."
        color: Theme.textMuted
        font.pixelSize: Theme.fontLabel
    }

    // -- Process : Audio ---------------------------------------------------
    Process {
        id: audioRead
        command: ["pactl", "get-sink-volume", "@DEFAULT_SINK@"]
        stdout: StdioCollector {
            onStreamFinished: {
                var m = text.match(/(\d+)%/)
                if (!audioSet.running && !audioWriteDelay.running)
                    root.audioPct = m ? parseInt(m[1]) : 0
                root.loaded = true
            }
        }
    }
    Process {
        id: sinkNameRead
        command: ["bash", "/home/toubi/.config/quickshell/nord-violet-cc/scripts/audiosink.sh"]
        stdout: StdioCollector {
            onStreamFinished: {
                var parts = text.trim().split("\t")
                if (parts.length >= 1 && parts[0].length > 0) root.audioSinkName = parts[0]
                root.audioSink = parts.length >= 2 && parts[1].length > 0 ? parts[1] : root.audioSinkName
            }
        }
        Component.onCompleted: running = true
    }
    Process { id: audioSet; onExited: audioRead.running = true }
    Timer {
        id: audioWriteDelay
        interval: 60
        onTriggered: {
            if (audioSet.running) { restart(); return }
            audioSet.command = ["python3", "/home/toubi/.config/quickshell/nord-violet-cc/scripts/audio-devices.py", "set-volume", root.audioPct + "%"]
            audioSet.running = true
        }
    }
    Process { id: sinkSet }

    // -- Process : liste des sorties dispo (picker) -------------------------
    Process {
        id: audioSinksRead
        command: ["bash", "/home/toubi/.config/quickshell/nord-violet-cc/scripts/audiosinks.sh"]
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = text.trim().split("\n")
                var out = []
                for (var i = 0; i < lines.length; i++) {
                    if (lines[i].length === 0) continue
                    var parts = lines[i].split("\t")
                    out.push({ name: parts[0] || "", desc: parts.length >= 2 && parts[1].length > 0 ? parts[1] : parts[0] })
                }
                root.audioSinks = out
            }
        }
    }

    // Écoute continue des événements PulseAudio/PipeWire (changement de
    // volume, de sink par défaut, etc.) pour resynchroniser la carte
    // Audio sans attendre le Timer. Voir avertissement en tête de fichier.
    Process {
        id: audioSubscribe
        command: ["pactl", "subscribe"]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: (line) => {
                if (!root.pollingActive) return
                if (line.indexOf(" on sink #") >= 0 || line.indexOf(" on server #") >= 0)
                    audioRefreshDelay.start()
            }
        }
    }

    Timer {
        id: audioRefreshDelay
        interval: 35
        onTriggered: {
            if (!root.pollingActive) return
            if (audioRead.running || sinkNameRead.running) { restart(); return }
            audioRead.running = true
            sinkNameRead.running = true
        }
    }

    // -- Process : Réseau (première connexion active) ----------------------
    Process {
        id: netRead
        command: ["nmcli", "-t", "-g", "NAME,TYPE,DEVICE", "connection", "show", "--active"]
        stdout: StdioCollector {
            onStreamFinished: {
                var line = text.trim().split("\n")[0]
                if (line && line.length > 0) {
                    var parts = line.split(":")
                    root.netName = parts[0] || ""
                    root.netType = parts[1] || ""
                    root.netDevice = parts[2] || ""
                    root.netConnected = true
                } else {
                    root.netConnected = false
                    root.netDevice = ""
                    root.netPrevRx = -1
                    root.netPrevTx = -1
                }
            }
        }
    }

    // v14 : débit réseau (demande explicite). Échantillonne
    // rx_bytes/tx_bytes de l'interface active toutes les 2s, calcule le
    // delta -> octets/s. Premier échantillon après un changement
    // d'interface = pas de delta dispo (netPrevRx/Tx à -1), donc pas de
    // débit affiché ce coup-là (voir `meta` du HeroStat Réseau).
    Process {
        id: netSpeedRead
        stdout: StdioCollector {
            onStreamFinished: {
                var parts = text.trim().split("\t")
                if (parts.length < 2) return
                var rx = parseFloat(parts[0])
                var tx = parseFloat(parts[1])
                if (root.netPrevRx >= 0) {
                    root.netRxRate = Math.max(0, (rx - root.netPrevRx) / 2)
                    root.netTxRate = Math.max(0, (tx - root.netPrevTx) / 2)
                }
                root.netPrevRx = rx
                root.netPrevTx = tx
            }
        }
    }
    Timer {
        interval: 2000
        running: root.pollingActive
        repeat: true
        onTriggered: {
            if (root.netDevice.length === 0) return
            netSpeedRead.command = ["bash", "/home/toubi/.config/quickshell/nord-violet-cc/scripts/netspeed.sh", root.netDevice]
            netSpeedRead.running = true
        }
    }

    // -- Process : Wi-Fi (volet, v16) ----------------------------------------
    // Même commandes nmcli que ConnectionsPage.qml (voir commentaire sur
    // splitNmcli plus haut pour le pourquoi de la duplication).
    Process {
        id: wifiRadioRead
        command: ["nmcli", "-t", "-f", "WIFI", "radio"]
        stdout: StdioCollector {
            onStreamFinished: root.wifiEnabled = text.trim().toLowerCase() === "enabled"
        }
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
        interval: 1500
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
                var lines = text.split("\n").filter(l => l.length > 0)
                var seen = {}
                var rows = []
                for (var i = 0; i < lines.length; i++) {
                    var f = root.splitNmcli(lines[i])
                    if (f.length < 4) continue
                    var ssid = f[1]
                    if (ssid.length === 0) continue
                    var signal = parseInt(f[2]) || 0
                    var entry = { active: f[0] === "yes", ssid: ssid, signal: signal, security: f[3].length ? f[3] : "--" }
                    if (seen[ssid] === undefined) { seen[ssid] = rows.length; rows.push(entry) }
                    else if (rows[seen[ssid]].signal < signal) rows[seen[ssid]] = entry
                }
                rows.sort((a, b) => b.signal - a.signal)
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
            onStreamFinished: {
                if (text.trim().length > 0) root.wifiStatusText = "Échec : " + text.trim().split("\n")[0]
            }
        }
    }

    // -- Process : DND (mako) ------------------------------------------------
    Process {
        id: dndRead
        command: ["makoctl", "mode"]
        stdout: StdioCollector {
            onStreamFinished: root.dndOn = text.split("\n").indexOf("dnd") >= 0
        }
    }
    Process { id: dndSet }
    Process { id: notificationsOpen; command: ["qs", "-c", "nord-violet-cc", "ipc", "call", "settings", "page", "notifications"] }

    // -- Process : profils et session Focus ---------------------------------
    Process {
        id: profileRead
        command: ["/home/toubi/.config/quickshell/nord-violet-cc/scripts/profilectl.sh", "status"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.profileKey = text.trim()
                var labels = { work: "Travail", mobile: "Nomade", game: "Jeu", night: "Nuit" }
                root.profileName = labels[root.profileKey] || "Personnalisé"
            }
        }
    }
    Process {
        id: profileApply
        onExited: {
            profileRead.running = true
            dndRead.running = true
        }
    }
    Process {
        id: focusRead
        command: ["/home/toubi/.config/quickshell/nord-violet-cc/scripts/focusctl.sh", "status"]
        stdout: StdioCollector {
            onStreamFinished: {
                var parts = text.trim().split("|")
                root.focusActive = parts[0] === "active"
                root.focusPaused = parts[0] === "paused"
                root.focusRemaining = parts.length > 1 ? parseInt(parts[1]) || 0 : 0
            }
        }
    }
    Process {
        id: focusToggle
        onExited: {
            focusRead.running = true
            dndRead.running = true
        }
    }
    Timer { interval: 1000; running: root.pollingActive; repeat: true; onTriggered: if (!focusRead.running) focusRead.running = true }

    // -- Process : Bluetooth (lecture seule) --------------------------------
    Process {
        id: btPoweredRead
        command: ["bluetoothctl", "show"]
        stdout: StdioCollector {
            onStreamFinished: root.btPowered = /Powered:\s*yes/.test(text)
        }
    }
    Process {
        id: btDeviceRead
        command: ["bash", "-c", "bluetoothctl devices Connected | head -1 | cut -d' ' -f3-"]
        stdout: StdioCollector {
            onStreamFinished: root.btDevice = text.trim()
        }
    }

    // Filet de sécurité pour tout ce qui n'a pas d'écoute event-driven
    // (réseau, bluetooth, dnd).
    Timer {
        interval: 15000
        running: root.pollingActive
        repeat: true
        onTriggered: root.reload()
    }

    Component.onCompleted: root.reload()
}
