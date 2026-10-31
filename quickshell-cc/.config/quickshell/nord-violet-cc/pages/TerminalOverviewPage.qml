import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../components"
import "../theme"

ColumnLayout {
    id: root
    spacing: 14
    property bool pollingActive: visible
    onPollingActiveChanged: if (pollingActive) root.reload()

    property string profile: "custom"
    property bool focusActive: false
    property bool focusPaused: false
    property int focusSeconds: 0
    property int brightness: 0
    property int audioVolume: 0
    property bool audioMuted: false
    property string audioName: "—"
    property int battery: 0
    property bool batteryPresent: false
    property int batteryLimit: 0
    property string chargeMode: "—"
    property string hyprVersion: "—"
    property string monitorName: "—"
    property string monitorMode: "—"

    function blocks(value) {
        var count = Math.max(0, Math.min(10, Math.round(value / 10)))
        return "█".repeat(count) + "░".repeat(10 - count) + " " + value + "%"
    }

    function reload() {
        profileRead.running = true
        focusRead.running = true
        brightnessRead.running = true
        audioRead.running = true
        systemRead.running = true
        hyprRead.running = true
        monitorsRead.running = true
    }

    component StatusRow: Item {
        property string label: ""
        property string detail: ""
        property string value: ""
        property color valueColor: Theme.textPrimary
        default property alias control: slot.children
        Layout.fillWidth: true
        implicitHeight: 56
        Rectangle { anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom; height: 1; color: Theme.border }
        ColumnLayout {
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2
            Text { text: label; color: Theme.textPrimary; font.family: "JetBrains Mono"; font.pixelSize: 12 }
            Text { text: detail; color: Theme.textMuted; font.family: "JetBrains Mono"; font.pixelSize: 10 }
        }
        Text {
            anchors.right: parent.right
            anchors.rightMargin: 5
            anchors.verticalCenter: parent.verticalCenter
            visible: value.length > 0
            text: value; color: valueColor; font.family: "JetBrains Mono"; font.pixelSize: 11
        }
        Item {
            id: slot
            anchors.right: parent.right
            anchors.rightMargin: 5
            anchors.verticalCenter: parent.verticalCenter
            visible: children.length > 0
            implicitWidth: children.length ? children[0].implicitWidth : 0
            implicitHeight: children.length ? children[0].implicitHeight : 0
        }
    }

    component TerminalSection: ColumnLayout {
        property string title: ""
        default property alias rows: rows.children
        Layout.fillWidth: true
        spacing: 0
        Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border }
        Text { Layout.topMargin: 10; Layout.bottomMargin: 5; text: "[ " + title + " ]"; color: Theme.accent; font.family: "JetBrains Mono"; font.pixelSize: 11 }
        ColumnLayout { id: rows; Layout.fillWidth: true; spacing: 0 }
    }

    TerminalSection {
        title: "SESSION"
        StatusRow {
            label: "Profil actif"
            detail: "Énergie, luminosité, DND et VRR"
            RowLayout {
                spacing: 6
                Repeater {
                    model: [{k:"work",n:"TRAVAIL"},{k:"mobile",n:"NOMADE"},{k:"game",n:"JEU"},{k:"night",n:"NUIT"}]
                    Rectangle {
                        required property var modelData
                        implicitWidth: profileLabel.implicitWidth + 16
                        implicitHeight: 29
                        radius: 1
                        color: root.profile === modelData.k ? Theme.accentMuted : "transparent"
                        border.width: 1
                        border.color: root.profile === modelData.k ? Theme.accent : Theme.border
                        Text { id: profileLabel; anchors.centerIn: parent; text: modelData.n; color: root.profile === modelData.k ? Theme.textPrimary : Theme.textMuted; font.family: "JetBrains Mono"; font.pixelSize: 10 }
                        TapHandler { onTapped: { profileApply.command = ["/home/toubi/.config/quickshell/nord-violet-cc/scripts/profilectl.sh", modelData.k]; profileApply.running = true } }
                    }
                }
            }
        }
        StatusRow {
            label: "Focus"
            detail: "Session autonome avec restauration DND"
            value: root.focusPaused ? Math.ceil(root.focusSeconds / 60) + " MIN · PAUSE" : root.focusActive ? Math.ceil(root.focusSeconds / 60) + " MIN · ACTIF" : "50:00 · PRÊT"
            valueColor: root.focusActive ? Theme.success : Theme.textPrimary
        }
    }

    TerminalSection {
        title: "MATÉRIEL"
        StatusRow { label: "Écran actif"; detail: root.monitorName; value: root.monitorMode }
        SettingsCard {
            SliderRow {
                label: "Luminosité · écran interne"
                from: 1
                value: root.brightness
                showDivider: false
                onMoved: value => { root.brightness = Math.round(value); brightnessDelay.restart() }
            }
        }
        SettingsCard {
            SliderRow {
                label: "Volume · " + root.audioName + (root.audioMuted ? " · MUET" : "")
                value: root.audioVolume
                showDivider: false
                onMoved: value => { root.audioVolume = Math.round(value); volumeDelay.restart() }
            }
        }
    }

    TerminalSection {
        title: "ÉTAT"
        StatusRow { label: "Batterie"; detail: root.batteryPresent ? "Protection firmware " + root.chargeMode : "Aucune batterie détectée"; value: root.batteryPresent ? root.battery + "% · limite " + root.batteryLimit + "%" : "—"; valueColor: root.batteryPresent && root.batteryLimit === 80 ? Theme.success : Theme.textPrimary }
        StatusRow { label: "Hyprland"; detail: "Version du compositeur actif"; value: root.hyprVersion }
    }

    Item { Layout.fillHeight: true }

    Process { id: profileRead; command: ["/home/toubi/.config/quickshell/nord-violet-cc/scripts/profilectl.sh", "status"]; stdout: StdioCollector { onStreamFinished: root.profile = text.trim() } }
    Process { id: profileApply; onExited: root.reload() }
    Process { id: focusRead; command: ["/home/toubi/.config/quickshell/nord-violet-cc/scripts/focusctl.sh", "status"]; stdout: StdioCollector { onStreamFinished: { var p=text.trim().split("|"); root.focusActive=p[0]==="active"; root.focusPaused=p[0]==="paused"; root.focusSeconds=p.length>1 ? parseInt(p[1])||0 : 0 } } }
    Process { id: brightnessRead; command: ["brightnessctl", "-m"]; stdout: StdioCollector { onStreamFinished: { if (!brightnessWrite.running && !brightnessDelay.running) { var m=text.match(/,(\d+)%,/); root.brightness=m ? parseInt(m[1]) : 0 } } } }
    Timer { id: brightnessDelay; interval: 80; onTriggered: { if (brightnessWrite.running) { restart(); return }; brightnessWrite.command=["brightnessctl", "set", root.brightness+"%"]; brightnessWrite.running=true } }
    Process { id: brightnessWrite; onExited: brightnessRead.running=true }
    Timer { id: volumeDelay; interval: 80; onTriggered: { if (volumeWrite.running) { restart(); return }; volumeWrite.command=["python3", "/home/toubi/.config/quickshell/nord-violet-cc/scripts/audio-devices.py", "set-volume", root.audioVolume+"%"]; volumeWrite.running=true } }
    Process { id: volumeWrite; onExited: audioRead.running=true }
    Process { id: audioRead; command: ["python3", "/home/toubi/.config/quickshell/nord-violet-cc/scripts/audio-devices.py", "snapshot"]; stdout: StdioCollector { onStreamFinished: { try { var s=JSON.parse(text); var c=s.sinks.find(x=>x.name===s.default); if(c){root.audioVolume=c.volume;root.audioMuted=c.muted;root.audioName=c.desc} } catch(e){} } } }
    Process {
        command: ["pactl", "subscribe"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                if (root.pollingActive && (data.indexOf(" on sink #") >= 0 || data.indexOf(" on server #") >= 0))
                    audioRefreshDelay.start()
            }
        }
    }
    Process { id: systemRead; command: ["python3", "/home/toubi/.config/quickshell/nord-violet-cc/scripts/system-info.py"]; stdout: StdioCollector { onStreamFinished: { try { var s=JSON.parse(text); root.batteryPresent=s.present===true; root.battery=s.capacity||0; root.batteryLimit=s.limit||0; root.chargeMode=s.chargeMode||"—" } catch(e){} } } }
    Process { id: hyprRead; command: ["hyprctl", "version", "-j"]; stdout: StdioCollector { onStreamFinished: { try { root.hyprVersion=JSON.parse(text).tag||"—" } catch(e){} } } }
    Process { id: monitorsRead; command: ["hyprctl", "monitors", "-j"]; stdout: StdioCollector { onStreamFinished: { try { var ms=JSON.parse(text); var m=ms.find(x=>x.focused)||ms[0]; if(m){root.monitorName=m.name+" · "+m.width+"×"+m.height;root.monitorMode=Math.round(m.refreshRate)+" Hz"} } catch(e){} } } }
    Timer {
        id: audioRefreshDelay
        interval: 35
        onTriggered: {
            if (!root.pollingActive) return
            if (audioRead.running || volumeWrite.running || volumeDelay.running) { restart(); return }
            audioRead.running = true
        }
    }
    Timer { interval: 5000; running: root.pollingActive; repeat: true; onTriggered: root.reload() }
    Component.onCompleted: root.reload()
}
