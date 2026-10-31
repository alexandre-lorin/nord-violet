import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../theme"
import "../components"

ColumnLayout {
    id: root
    spacing: 8
    signal toastRequested(string message)

    property string versionLine: "…"
    property string layoutMode: "dwindle"
    property bool animationsOn: true
    property bool blurOn: true
    property int borderSize: 2
    property var workspaces: []
    readonly property string scriptPath: "/home/toubi/.config/quickshell/nord-violet-cc/scripts/hyprlandctl.py"

    function refresh() {
        statusProc.running = true
        workspacesProc.running = true
    }
    function runAction(args, message) {
        actionProc.command = [scriptPath].concat(args)
        actionProc.successMessage = message
        actionProc.running = true
    }

    StatusCard {
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6
                Text { text: "COMPOSITEUR / ÉTAT RÉEL"; color: Theme.accent; font.pixelSize: 9; font.bold: true; font.letterSpacing: 1.4 }
                Text { text: root.versionLine.split(" built")[0]; color: Theme.textPrimary; font.family: "JetBrains Mono"; font.pixelSize: 16; elide: Text.ElideRight; Layout.fillWidth: true }
                Text { text: root.workspaces.length + " bureaux actifs · disposition " + root.layoutMode; color: Theme.textMuted; font.pixelSize: Theme.fontLabel }
            }
            Rectangle {
                Layout.preferredWidth: 74
                Layout.minimumWidth: 74
                Layout.maximumWidth: 74
                Layout.fillWidth: false
                Layout.preferredHeight: 30
                Layout.alignment: Qt.AlignVCenter
                radius: 2
                color: Theme.accentMuted; border.width: 1; border.color: Theme.accent
                Text { anchors.centerIn: parent; text: "LIVE"; color: Theme.accent; font.pixelSize: 10; font.bold: true; font.letterSpacing: 1.2 }
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
            SectionHeader { text: "COMPORTEMENT"; first: true }
            SettingsCard {
                SelectRow {
                    label: "Disposition des fenêtres"
                    model: [{ label: "Dwindle", value: "dwindle" }, { label: "Master", value: "master" }]
                    currentValue: root.layoutMode
                    onSelected: value => root.runAction(["layout", value], "Disposition " + value + " appliquée")
                }
                SelectRow {
                    label: "Épaisseur des bordures"
                    model: [{ label: "Aucune", value: "0" }, { label: "Fine", value: "2" }, { label: "Forte", value: "3" }]
                    currentValue: String(root.borderSize)
                    showDivider: false
                    onSelected: value => root.runAction(["border", value], "Bordures mises à jour")
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true; Layout.alignment: Qt.AlignTop; spacing: Theme.spacingXS
            SectionHeader { text: "RENDU"; first: true }
            SettingsCard {
                ToggleRow {
                    label: "Animations Hyprland"
                    subtext: "Fenêtres, fondus et workspaces"
                    checked: root.animationsOn
                    onToggled: state => root.runAction(["animations", state ? "on" : "off"], state ? "Animations activées" : "Animations coupées")
                }
                ToggleRow {
                    label: "Flou des surfaces"
                    subtext: "Effet natif du compositeur"
                    checked: root.blurOn
                    showDivider: false
                    onToggled: state => root.runAction(["blur", state ? "on" : "off"], state ? "Flou activé" : "Flou coupé")
                }
            }
            SectionHeader { text: "CONFIGURATION" }
            SettingsCard {
                RowButton { label: "Recharger Hyprland"; showChevron: true; onClicked: root.runAction(["reload"], "Configuration rechargée") }
                RowButton { label: "Ouvrir les fichiers"; showChevron: true; showDivider: false; onClicked: configOpen.running = true }
            }
        }
    }

    SectionHeader { text: "BUREAUX ACTIFS" }
    SettingsCard {
        Text {
            Layout.fillWidth: true; Layout.margins: Theme.spacingMD
            visible: root.workspaces.length === 0
            text: "Aucun bureau détecté"; color: Theme.textMuted; font.pixelSize: Theme.fontLabel
        }
        Repeater {
            model: root.workspaces
            delegate: RowButton {
                label: "Bureau " + modelData.id
                value: modelData.windows + " fenêtre" + (modelData.windows > 1 ? "s" : "") + " · " + modelData.monitor
                showChevron: true
                showDivider: index < root.workspaces.length - 1
                onClicked: {
                    workspaceSwitch.command = ["hyprctl", "dispatch", "workspace", String(modelData.id)]
                    workspaceSwitch.running = true
                }
            }
        }
    }

    Process {
        id: statusProc
        command: [root.scriptPath, "status"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(text)
                    root.versionLine = data.version
                    root.layoutMode = data.layout
                    root.animationsOn = data.animations
                    root.blurOn = data.blur
                    root.borderSize = data.border
                } catch (error) {}
            }
        }
    }
    Process {
        id: workspacesProc
        command: ["hyprctl", "workspaces", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var rows = JSON.parse(text)
                    rows.sort(function(a, b) { return a.id - b.id })
                    root.workspaces = rows.filter(w => w.id >= 0)
                } catch (error) { root.workspaces = [] }
            }
        }
    }
    Process {
        id: actionProc
        property string successMessage: ""
        onExited: (code) => {
            root.refresh()
            root.toastRequested(code === 0 ? successMessage : "Modification impossible")
        }
    }
    Process { id: configOpen; command: ["xdg-open", "/home/toubi/.config/hypr"] }
    Process { id: workspaceSwitch }

    Component.onCompleted: root.refresh()
}
