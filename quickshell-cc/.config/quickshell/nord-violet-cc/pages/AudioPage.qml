import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../theme"
import "../components"

// v32 — RÉELLE : mêmes commandes pactl que AudioFlyout.qml (volume +
// liste des sorties), juste présentées en page de réglages complète
// plutôt qu'en popup compact. État propre à cette page (pas de state
// partagé avec AudioFlyout — même duplication déjà acceptée ailleurs
// dans ce projet, voir HANDOFF).
ColumnLayout {
    id: root
    spacing: 8

    property int audioPct: 0
    property bool audioMuted: false
    property bool loaded: false
    property string readError: ""
    property string audioSinkName: ""
    property var audioSinks: []
    property int micPct: 0
    property bool micMuted: false
    property string audioSourceName: ""
    property var audioSources: []

    function refreshVolume() { refreshSources() }
    function refreshSinkName() { refreshSources() }
    function refreshSinks() { refreshSources() }
    function refreshSources() { refreshDelay.restart() }

    function setVolume(pct) {
        pct = Math.max(0, Math.min(100, Math.round(pct)))
        audioPct = pct
        volumeWriteDelay.restart()
    }

    function selectSink(name) {
        sinkSetProc.command = ["python3", "/home/toubi/.config/quickshell/nord-violet-cc/scripts/audio-devices.py", "select", name]
        sinkSetProc.running = true
        // pactl ne redonne pas la main tout de suite sur le nouveau
        // sink par défaut — petit délai avant de relire, même
        // tolérance que le reste du projet pour ce genre de course.
        sinkRefreshDelay.start()
    }

    function setMicVolume(pct) {
        pct = Math.max(0, Math.min(100, Math.round(pct)))
        micPct = pct
        micWriteDelay.restart()
    }

    function toggleMic() {
        micMuted = !micMuted
        micMuteProc.running = true
    }

    function selectSource(name) {
        sourceSetProc.command = ["python3", "/home/toubi/.config/quickshell/nord-violet-cc/scripts/audio-devices.py", "select-source", name]
        sourceSetProc.running = true
        sourceRefreshDelay.start()
    }

    Timer { id: sinkRefreshDelay; interval: 200; onTriggered: { root.refreshSinkName(); root.refreshSinks() } }
    Timer { id: sourceRefreshDelay; interval: 200; onTriggered: root.refreshSources() }
    Timer { id: refreshDelay; interval: 80; onTriggered: {
        if (audioSourcesReadProc.running || audioSetProc.running || micSetProc.running || volumeWriteDelay.running || micWriteDelay.running)
            restart()
        else audioSourcesReadProc.running = true
    } }
    Timer { id: volumeWriteDelay; interval: 60; onTriggered: {
        if (audioSetProc.running) { restart(); return }
        audioSetProc.command = ["python3", "/home/toubi/.config/quickshell/nord-violet-cc/scripts/audio-devices.py", "set-volume", root.audioPct + "%"]
        audioSetProc.running = true
    } }
    Timer { id: micWriteDelay; interval: 60; onTriggered: {
        if (micSetProc.running) { restart(); return }
        micSetProc.command = ["python3", "/home/toubi/.config/quickshell/nord-violet-cc/scripts/audio-devices.py", "set-source-volume", root.micPct + "%"]
        micSetProc.running = true
    } }
    Timer { interval: 2000; running: root.visible; repeat: true; onTriggered: root.refreshSources() }

    Component.onCompleted: {
        refreshVolume()
        refreshSinkName()
        refreshSinks()
        refreshSources()
    }

    Process { id: audioSetProc; onExited: root.refreshSources() }
    Process { id: sinkSetProc }
    Process { id: micSetProc; onExited: root.refreshSources() }
    Process {
        id: audioMuteProc
        command: ["python3", "/home/toubi/.config/quickshell/nord-violet-cc/scripts/audio-devices.py", "toggle-mute"]
        onExited: root.refreshSources()
    }
    Process {
        id: micMuteProc
        command: ["python3", "/home/toubi/.config/quickshell/nord-violet-cc/scripts/audio-devices.py", "toggle-source-mute"]
        onExited: root.refreshSources()
    }
    Process { id: sourceSetProc }
    Process {
        id: audioSourcesReadProc
        command: ["python3", "/home/toubi/.config/quickshell/nord-violet-cc/scripts/audio-devices.py", "snapshot"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(text)
                    root.loaded = true
                    root.readError = ""
                    root.audioSinks = data.sinks || []
                    root.audioSinkName = data.default || ""
                    var sink = root.audioSinks.find(s => s.name === root.audioSinkName)
                    if (!audioSetProc.running && !volumeWriteDelay.running) root.audioPct = sink ? sink.volume : 0
                    root.audioMuted = sink ? sink.muted : false
                    root.audioSources = data.sources || []
                    root.audioSourceName = data.defaultSource || ""
                    for (var i = 0; i < root.audioSources.length; i++) {
                        if (root.audioSources[i].name === root.audioSourceName) {
                            if (!micSetProc.running && !micWriteDelay.running) root.micPct = root.audioSources[i].volume
                            root.micMuted = root.audioSources[i].muted
                            break
                        }
                    }
                } catch (error) { root.readError = "Lecture audio indisponible" }
            }
        }
    }

    SectionHeader { text: "VOLUME"; first: true }
    SettingsCard {
        SliderRow {
            label: "Volume de sortie"
            value: root.audioPct
            unit: "%"
            onMoved: (v) => root.setVolume(v)
        }
        ToggleRow {
            label: "Sortie active"
            subtext: root.audioMuted ? "Son coupé" : "Son autorisé"
            checked: !root.audioMuted
            showDivider: false
            onToggled: { if (!audioMuteProc.running) audioMuteProc.running = true }
        }
    }

    SectionHeader { text: "APPAREILS" }
    SettingsCard {
        Text {
            Layout.fillWidth: true
            Layout.margins: Theme.spacingMD
            visible: root.audioSinks.length === 0
            text: root.readError || (root.loaded ? "Aucune sortie détectée" : "Chargement…")
            color: Theme.textMuted
            font.pixelSize: Theme.fontLabel
        }

        Repeater {
            model: root.audioSinks

            // Pas de `required property` ici — même convention que le
            // reste du projet (voir WifiFlyout.qml) : `modelData`/`index`
            // restent des propriétés de contexte implicites, pas de
            // `pragma ComponentBehavior: Bound` dans ce fichier.
            delegate: RowButton {
                label: modelData.desc
                value: modelData.name === root.audioSinkName ? "Actif" : ""
                showDivider: index < root.audioSinks.length - 1
                onClicked: root.selectSink(modelData.name)
            }
        }
    }

    SectionHeader { text: "MICROPHONE" }
    SettingsCard {
        SliderRow {
            label: "Niveau d’entrée"
            value: root.micPct
            unit: "%"
            onMoved: (v) => root.setMicVolume(v)
        }
        ToggleRow {
            label: "Microphone actif"
            subtext: root.micMuted ? "Entrée coupée" : "Capture autorisée"
            checked: !root.micMuted
            showDivider: false
            onToggled: root.toggleMic()
        }
    }

    SectionHeader { text: "ENTRÉES" }
    SettingsCard {
        Text {
            Layout.fillWidth: true; Layout.margins: Theme.spacingMD
            visible: root.audioSources.length === 0
            text: "Aucun microphone détecté"; color: Theme.textMuted; font.pixelSize: Theme.fontLabel
        }
        Repeater {
            model: root.audioSources
            delegate: RowButton {
                label: modelData.desc
                value: modelData.name === root.audioSourceName ? "Actif" : modelData.detail
                showDivider: index < root.audioSources.length - 1
                onClicked: root.selectSource(modelData.name)
            }
        }
    }

    Process {
        id: audioSubscribe
        command: ["pactl", "subscribe"]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: (line) => {
                if (line.indexOf("source") >= 0 || line.indexOf("server") >= 0) root.refreshSources()
                if (line.indexOf("sink") >= 0 || line.indexOf("server") >= 0) {
                    root.refreshVolume(); root.refreshSinkName(); root.refreshSinks()
                }
            }
        }
    }

    Item { Layout.fillHeight: true }
}
