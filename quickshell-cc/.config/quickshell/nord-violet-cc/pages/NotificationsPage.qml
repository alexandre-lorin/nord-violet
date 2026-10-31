import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../theme"
import "../components"

ColumnLayout {
    id: root
    spacing: 8
    signal toastRequested(string message)
    property var currentItems: []
    property var historyItems: []
    property bool pollingActive: true
    readonly property string scriptPath: "/home/toubi/.config/quickshell/nord-violet-cc/scripts/notificationctl.py"

    function refresh() { if (!statusProc.running) statusProc.running = true }
    function action(args, message) { if (actionProc.running) return; actionProc.command = [scriptPath].concat(args); actionProc.successMessage = message; actionProc.running = true }
    function plain(value) { return String(value || "").replace(/<[^>]*>/g, "").trim() }

    StatusCard {
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6
                Text { text: "[ NOTIFICATIONS / MAKO ]"; color: Theme.accent; font.family: "JetBrains Mono"; font.pixelSize: 9; font.bold: true; font.letterSpacing: 1.4 }
                Text { text: "ACTIVES = " + root.currentItems.length; color: Theme.textPrimary; font.family: "JetBrains Mono"; font.pixelSize: 16 }
                Text { text: root.historyItems.length + " dans l’historique"; color: Theme.textMuted; font.pixelSize: Theme.fontLabel }
            }
            Rectangle {
                Layout.preferredWidth: 196
                Layout.minimumWidth: 196
                Layout.maximumWidth: 196
                Layout.fillWidth: false
                Layout.preferredHeight: 32
                Layout.alignment: Qt.AlignVCenter
                radius: 2
                opacity: root.historyItems.length > 0 && !actionProc.running ? 1 : 0.4
                color: restoreHover.hovered ? Theme.accentMuted : Theme.background
                border.width: 1; border.color: restoreHover.hovered ? Theme.accent : Theme.border
                Text { anchors.centerIn: parent; text: "RÉAFFICHER LA DERNIÈRE"; color: Theme.textPrimary; font.family: "JetBrains Mono"; font.pixelSize: 10 }
                HoverHandler { id: restoreHover }
                TapHandler { enabled: root.historyItems.length > 0 && !actionProc.running; onTapped: root.action(["restore"], "Notification restaurée") }
            }
    }

    SectionHeader { text: "ACTIVES" }
    SettingsCard {
        Text { Layout.fillWidth: true; Layout.margins: Theme.spacingMD; visible: root.currentItems.length === 0; text: "Aucune notification active"; color: Theme.textMuted; font.pixelSize: Theme.fontLabel }
        Repeater {
            model: root.currentItems
            delegate: RowButton {
                label: root.plain(modelData.summary) || modelData.app_name || "Notification"
                subtext: root.plain(modelData.body)
                value: "Classer"
                enabled: !actionProc.running
                showChevron: true; showDivider: index < root.currentItems.length - 1
                onClicked: root.action(["dismiss", String(modelData.id)], "Notification classée")
            }
        }
    }

    SectionHeader { text: "HISTORIQUE" }
    SettingsCard {
        Text { Layout.fillWidth: true; Layout.margins: Theme.spacingMD; visible: root.historyItems.length === 0; text: "Historique vide"; color: Theme.textMuted; font.pixelSize: Theme.fontLabel }
        Repeater {
            model: root.historyItems.slice(0, 12)
            delegate: RowButton {
                label: root.plain(modelData.summary) || modelData.app_name || "Notification"
                value: modelData.app_name || "Mako"
                subtext: root.plain(modelData.body)
                showDivider: index < Math.min(root.historyItems.length, 12) - 1
            }
        }
    }
    RowButton {
        visible: root.historyItems.length > 0; label: "Vider l’historique"; value: root.historyItems.length + " éléments"
        showChevron: true; showDivider: false
        onClicked: root.action(["clear-history"], "Historique effacé")
    }
    Item { Layout.fillHeight: true }

    Process {
        id: statusProc; command: [root.scriptPath, "status"]
        stdout: StdioCollector { onStreamFinished: { try { var data = JSON.parse(text); root.currentItems = data.current || []; root.historyItems = data.history || [] } catch (error) { root.currentItems = []; root.historyItems = [] } } }
    }
    Process {
        id: actionProc; property string successMessage: ""
        onExited: (code) => { root.refresh(); root.toastRequested(code === 0 ? successMessage : "Action impossible") }
    }
    Timer { interval: 5000; running: root.pollingActive; repeat: true; onTriggered: root.refresh() }
    onPollingActiveChanged: if (pollingActive) root.refresh()
    Component.onCompleted: root.refresh()
}
