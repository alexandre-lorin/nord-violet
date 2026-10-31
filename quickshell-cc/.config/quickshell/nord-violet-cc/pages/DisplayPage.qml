import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../theme"
import "../components"

ColumnLayout {
    id: root
    spacing: 8
    signal toastRequested(string message)

    property var monitors: []
    property int brightness: 0
    property string backlightDevice: ""
    property bool externalAvailable: false
    property int externalBrightness: 0
    property string externalStatus: "Lecture DDC/CI de HDMI-A-1…"
    readonly property string scriptPath: "/home/toubi/.config/quickshell/nord-violet-cc/scripts/displayctl.py"

    function refresh() { readProc.running = true }

    function nativeRates(mon) {
        var prefix = mon.width + "x" + mon.height + "@"
        var seen = {}
        var rows = []
        var modes = mon.availableModes || []
        for (var i = 0; i < modes.length; i++) {
            var mode = modes[i]
            if (mode.indexOf(prefix) !== 0) continue
            var rate = Math.round(parseFloat(mode.split("@")[1]))
            if (seen[rate]) continue
            seen[rate] = true
            rows.push({ label: rate + " Hz", value: String(rate) })
        }
        rows.sort(function(a, b) { return parseInt(a.value) - parseInt(b.value) })
        return rows
    }

    function setRate(name, rate) {
        rateProc.command = [scriptPath, "rate", name, rate]
        rateProc.running = true
    }

    Component.onCompleted: { refresh(); brightnessRead.running = true; externalRead.running = true }
    Process {
        id: externalRead
        command: ["python3", "/home/toubi/.config/quickshell/nord-violet-cc/scripts/monitor-brightness.py", "read", "HDMI-A-1"]
        stdout: StdioCollector { onStreamFinished: {
            try {
                var data=JSON.parse(text)
                root.externalAvailable=data.available===true
                root.externalStatus=data.available ? "HDMI-A-1 · luminosité de l’écran" : data.error
                if (data.available && !externalWrite.running && !externalDelay.running) root.externalBrightness=data.percent
            } catch(e) { root.externalStatus="Lecture DDC/CI impossible"; root.externalAvailable=false }
        } }
    }
    Timer {
        id: externalDelay; interval: 250
        onTriggered: {
            if (externalWrite.running || externalRead.running) { restart(); return }
            externalWrite.command=["python3", "/home/toubi/.config/quickshell/nord-violet-cc/scripts/monitor-brightness.py", "set", "HDMI-A-1", String(root.externalBrightness)]
            externalWrite.running=true
        }
    }
    Process { id: externalWrite; onExited: code => { if (code !== 0) root.toastRequested("Luminosité externe non appliquée"); if (!externalDelay.running) externalRead.running=true } }
    Timer { interval: 10000; running: root.visible; repeat: true; onTriggered: { if (!externalRead.running && !externalWrite.running && !externalDelay.running) externalRead.running=true } }
    Timer {
        interval: 1500; running: root.visible; repeat: true
        onTriggered: { if (!brightnessWrite.running && !brightnessDelay.running) brightnessRead.running = true }
    }
    Timer {
        id: brightnessDelay; interval: 80
        onTriggered: {
            if (brightnessWrite.running) { restart(); return }
            brightnessWrite.command = ["brightnessctl", "-d", root.backlightDevice, "set", root.brightness + "%"]
            brightnessWrite.running = true
        }
    }
    Process {
        id: brightnessRead; command: ["brightnessctl", "-m"]
        stdout: StdioCollector {
            onStreamFinished: {
                var fields = text.trim().split(",")
                if (fields.length >= 5) {
                    root.backlightDevice = fields[0]
                    if (!brightnessWrite.running && !brightnessDelay.running) root.brightness = parseInt(fields[3]) || 0
                }
            }
        }
    }
    Process {
        id: brightnessWrite
        onExited: code => {
            brightnessRead.running = true
            if (code !== 0) root.toastRequested("Luminosité non appliquée")
        }
    }

    Process {
        id: readProc
        command: ["hyprctl", "monitors", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try { root.monitors = JSON.parse(text) } catch (e) { root.monitors = [] }
            }
        }
    }
    Process {
        id: rateProc
        onExited: (code) => {
            root.refresh()
            root.toastRequested(code === 0 ? "Fréquence d’écran appliquée" : "Mode d’écran impossible")
        }
    }

    StatusCard {
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6
                Text { text: "[ AFFICHAGE / TOPOLOGIE ]"; color: Theme.accent; font.family: "JetBrains Mono"; font.pixelSize: 11 }
                Text { text: "MONITORS = " + root.monitors.length; color: Theme.textPrimary; font.family: "JetBrains Mono"; font.pixelSize: 16 }
                Text { text: "Positions et espaces de travail conservés"; color: Theme.textMuted; font.family: "JetBrains Mono"; font.pixelSize: 11 }
            }
            Text { Layout.fillWidth: false; text: "[ RELIRE ]"; color: refreshHover.hovered ? Theme.accent : Theme.textMuted; font.family: "JetBrains Mono"; font.pixelSize: 11
                HoverHandler { id: refreshHover }
                TapHandler { onTapped: root.refresh() }
            }
    }

    SectionHeader { text: "LUMINOSITÉ / ÉCRAN INTERNE"; visible: root.backlightDevice.length > 0 }
    SettingsCard {
        visible: root.backlightDevice.length > 0
        SliderRow {
            label: "Rétroéclairage · " + root.backlightDevice
            from: 1
            value: root.brightness
            showDivider: false
            onMoved: value => { root.brightness = Math.round(value); brightnessDelay.restart() }
        }
    }

    Text {
        Layout.fillWidth: true
        visible: root.monitors.length === 0
        text: "Chargement…"
        color: Theme.textMuted
        font.pixelSize: Theme.fontLabel
    }

    SectionHeader { text: "LUMINOSITÉ / ÉCRAN EXTERNE" }
    SettingsCard {
        SliderRow {
            visible: root.externalAvailable
            label: "HDMI-A-1 · DDC/CI"
            value: root.externalBrightness
            showDivider: false
            onMoved: value => { root.externalBrightness=Math.round(value); externalDelay.restart() }
        }
        RowButton {
            label: root.externalStatus
            value: "Relire"
            showDivider: false
            onClicked: { if (!externalWrite.running) externalRead.running=true }
        }
    }

    Repeater {
        model: root.monitors

        delegate: ColumnLayout {
            id: monDelegate
            readonly property var mon: modelData

            Layout.fillWidth: true
            spacing: 0

            SectionHeader {
                text: monDelegate.mon.name + (monDelegate.mon.focused ? " (actif)" : "")
            }

            SettingsCard {
                RowButton {
                    label: "Résolution"
                    value: monDelegate.mon.width + " × " + monDelegate.mon.height
                }
                RowButton {
                    label: "Taux de rafraîchissement"
                    value: Math.round(monDelegate.mon.refreshRate) + " Hz"
                }
                SelectRow {
                    label: "Fréquence native"
                    model: root.nativeRates(monDelegate.mon)
                    currentValue: String(Math.round(monDelegate.mon.refreshRate))
                    onSelected: value => root.setRate(monDelegate.mon.name, value)
                }
                RowButton {
                    label: "Position"
                    value: monDelegate.mon.x + ", " + monDelegate.mon.y
                }
                RowButton {
                    label: "Mise à l'échelle"
                    value: monDelegate.mon.scale
                    showDivider: false
                }
            }
        }
    }


    Item { Layout.fillHeight: true }

    Text {
        Layout.fillWidth: true
        text: "DDC/CI règle le moniteur HDMI ; le rétroéclairage interne reste indépendant. Molette : 1 % par cran."
        color: Theme.textMuted
        font.family: "JetBrains Mono"
        font.pixelSize: 11
        wrapMode: Text.WordWrap
    }
}
