import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../theme"
import "../components"

ColumnLayout {
    id: root
    spacing: 8
    signal toastRequested(string message)

    property string ramLine: "…"
    property string diskLine: "…"
    property string uptimeLine: "…"
    property string loadLine: "…"
    property string hostnameLine: "…"
    property string kernelLine: "…"
    property int batteryPct: 0
    property string batteryStatus: "…"
    property int batteryCycles: 0
    property int batteryHealth: 0
    property int chargeLimit: 100
    property string chargeMode: "Standard"
    property string powerProfile: "…"
    property string modelName: "…"
    property string cpuName: "…"

    function refresh() {
        ramProc.running = true
        diskProc.running = true
        uptimeProc.running = true
        loadProc.running = true
        hostnameProc.running = true
        kernelProc.running = true
        hardwareProc.running = true
    }

    StatusCard {
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6
                Text { text: "BATTERIE / PROTECTION"; color: Theme.accent; font.pixelSize: 9; font.bold: true; font.letterSpacing: 1.4 }
                Text { text: "BATTERY = " + root.batteryPct + "%"; color: Theme.textPrimary; font.family: "JetBrains Mono"; font.pixelSize: 16 }
                Text { text: root.batteryStatus + " · santé " + root.batteryHealth + "% · " + root.batteryCycles + " cycles"; color: Theme.textMuted; font.pixelSize: Theme.fontLabel }
            }
            Rectangle {
                Layout.preferredWidth: 126
                Layout.minimumWidth: 126
                Layout.maximumWidth: 126
                Layout.fillWidth: false
                Layout.preferredHeight: 50
                Layout.alignment: Qt.AlignVCenter
                radius: 2
                color: root.chargeLimit === 80 ? Theme.accentMuted : Theme.background
                border.width: 1
                border.color: root.chargeLimit === 80 ? Theme.accent : Theme.border
                Column {
                    anchors.centerIn: parent; spacing: 3
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "LIMITE " + root.chargeLimit + "%"; color: root.chargeLimit === 80 ? Theme.accent : Theme.textPrimary; font.pixelSize: 11; font.bold: true }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: root.chargeMode; color: Theme.textMuted; font.pixelSize: 9 }
                }
            }
    }

    GridLayout {
        Layout.topMargin: 14
        Layout.fillWidth: true
        columns: width >= 760 ? 2 : 1
        columnSpacing: Theme.spacingMD
        rowSpacing: Theme.spacingMD

        ColumnLayout {
            Layout.fillWidth: true; Layout.alignment: Qt.AlignTop; spacing: Theme.spacingXS
            SectionHeader { text: "MACHINE"; first: true }
            SettingsCard {
                RowButton { label: "Nom"; value: root.hostnameLine }
                RowButton { label: "Modèle"; value: root.modelName }
                RowButton { label: "Processeur"; value: root.cpuName }
                RowButton { label: "Kernel"; value: root.kernelLine }
                RowButton { label: "Uptime"; value: root.uptimeLine }
                RowButton { label: "Profil énergétique"; value: root.powerProfile; showDivider: false }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true; Layout.alignment: Qt.AlignTop; spacing: Theme.spacingXS
            SectionHeader { text: "RESSOURCES"; first: true }
            SettingsCard {
                RowButton { label: "RAM utilisée"; value: root.ramLine }
                RowButton { label: "Disque système"; value: root.diskLine }
                RowButton { label: "Charge 1 / 5 / 15 min"; value: root.loadLine }
                RowButton {
                    label: "Ouvrir le monitoring"
                    value: "btop"
                    showChevron: true
                    showDivider: false
                    onClicked: monitoringProc.running = true
                }
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Text {
            Layout.fillWidth: true
            text: root.chargeLimit === 80
                ? "La protection Long Life est active : la charge s’arrête autour de 80 %."
                : "La protection 80 % n’est pas active actuellement."
            color: root.chargeLimit === 80 ? Theme.textMuted : Theme.warning
            font.pixelSize: Theme.fontLabel
        }
        Text { text: "ACTUALISER"; color: refreshHover.hovered ? Theme.accent : Theme.textMuted; font.pixelSize: 9; font.bold: true }
        HoverHandler { id: refreshHover }
        TapHandler { onTapped: root.refresh() }
    }
    Item { Layout.fillHeight: true }

    Process { id: ramProc; command: ["bash", "-c", "free -h | awk '/^Mem:/ {print $3 \" / \" $2}'"]; stdout: StdioCollector { onStreamFinished: root.ramLine = text.trim() || "indisponible" } }
    Process { id: diskProc; command: ["bash", "-c", "df -h / | awk 'NR==2 {print $3 \" / \" $2 \" (\" $5 \")\"}'"]; stdout: StdioCollector { onStreamFinished: root.diskLine = text.trim() || "indisponible" } }
    Process { id: uptimeProc; command: ["uptime", "-p"]; stdout: StdioCollector { onStreamFinished: root.uptimeLine = text.trim().replace(/^up /, "") || "indisponible" } }
    Process {
        id: loadProc; command: ["cat", "/proc/loadavg"]
        stdout: StdioCollector { onStreamFinished: { var parts = text.trim().split(" "); root.loadLine = parts.length >= 3 ? parts.slice(0, 3).join(" / ") : "indisponible" } }
    }
    Process { id: hostnameProc; command: ["uname", "-n"]; stdout: StdioCollector { onStreamFinished: root.hostnameLine = text.trim() || "indisponible" } }
    Process { id: kernelProc; command: ["uname", "-r"]; stdout: StdioCollector { onStreamFinished: root.kernelLine = text.trim() || "indisponible" } }
    Process {
        id: hardwareProc
        command: ["/home/toubi/.config/quickshell/nord-violet-cc/scripts/system-info.py"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(text)
                    root.batteryPct = data.capacity || 0
                    root.batteryStatus = data.status || "Inconnue"
                    root.batteryCycles = data.cycles || 0
                    root.batteryHealth = data.health || 0
                    root.chargeLimit = data.limit || 100
                    root.chargeMode = data.chargeMode || "Standard"
                    root.powerProfile = data.powerProfile || "indisponible"
                    root.modelName = data.model || "—"
                    root.cpuName = data.cpu || "—"
                } catch (error) {}
            }
        }
    }
    Process {
        id: monitoringProc
        command: ["/home/toubi/.config/hypr/scripts/toggle-app.sh", "monitoring", "monitoring", "alacritty --class monitoring -e btop --update 100"]
        onExited: root.toastRequested("Monitoring ouvert")
    }
    Timer { interval: 30000; running: true; repeat: true; onTriggered: root.refresh() }
    Component.onCompleted: root.refresh()
}
