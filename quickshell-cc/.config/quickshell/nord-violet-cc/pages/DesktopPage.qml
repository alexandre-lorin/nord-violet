import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../theme"
import "../components"

ColumnLayout {
    id: root
    spacing: 8
    signal toastRequested(string message)

    property string density: "balanced"
    property int gapsIn: 4
    property int gapsOut: 8
    property int rounding: 9
    property int waybarOutputs: 0
    readonly property string scriptPath: "/home/toubi/.config/quickshell/nord-violet-cc/scripts/desktopctl.py"

    function refresh() { statusProc.running = true }
    function runAction(args, message) {
        actionProc.command = [scriptPath].concat(args)
        actionProc.successMessage = message
        actionProc.running = true
    }

    StatusCard {
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6
                Text { text: "[ BUREAU / ÉTAT ]"; color: Theme.accent; font.family: "JetBrains Mono"; font.pixelSize: 11 }
                Text { text: "WAYBAR = " + root.waybarOutputs + " SURFACES"; color: Theme.textPrimary; font.family: "JetBrains Mono"; font.pixelSize: 16 }
                Text { text: "gaps = " + root.gapsIn + "/" + root.gapsOut + " px · rounding = " + root.rounding + " px"; color: Theme.textMuted; font.family: "JetBrains Mono"; font.pixelSize: 11 }
            }
    }

    GridLayout {
        Layout.topMargin: 14
        Layout.fillWidth: true
        columns: 1
        columnSpacing: Theme.spacingMD
        rowSpacing: Theme.spacingMD

        ColumnLayout {
            Layout.fillWidth: true; Layout.alignment: Qt.AlignTop; spacing: Theme.spacingXS
            SectionHeader { text: "BARRE"; first: true }
            SettingsCard {
                RowButton {
                    label: "Afficher / masquer"
                    value: root.waybarOutputs + " écrans"
                    showChevron: true
                    onClicked: root.runAction(["bar-toggle"], "Visibilité de Waybar basculée")
                }
                RowButton {
                    label: "Recharger la configuration"
                    value: "Waybar"
                    showChevron: true
                    onClicked: root.runAction(["bar-reload"], "Waybar rechargée")
                }
                RowButton {
                    label: "Ouvrir la configuration"
                    showChevron: true
                    showDivider: false
                    onClicked: configOpen.running = true
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true; Layout.alignment: Qt.AlignTop; spacing: Theme.spacingXS
            SectionHeader { text: "FENÊTRES"; first: true }
            SettingsCard {
                SelectRow {
                    label: "Écart entre les fenêtres (Hyprland)"
                    model: [
                        { label: "Compact", value: "compact" },
                        { label: "Équilibré", value: "balanced" },
                        { label: "Aéré", value: "spacious" }
                    ]
                    currentValue: root.density
                    showDivider: false
                    onSelected: value => root.runAction(["density", value], "Densité du bureau appliquée")
                }
            }
        }
    }

    Text {
        Layout.fillWidth: true
        text: "Les changements de densité sont appliqués immédiatement et enregistrés dans la configuration Hyprland."
        color: Theme.textMuted
        font.pixelSize: Theme.fontLabel
        font.family: "JetBrains Mono"
        wrapMode: Text.WordWrap
    }
    Item { Layout.fillHeight: true }

    Process {
        id: statusProc
        command: [root.scriptPath, "status"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(text)
                    root.density = data.density
                    root.gapsIn = data.gapsIn
                    root.gapsOut = data.gapsOut
                    root.rounding = data.rounding
                    root.waybarOutputs = data.waybarOutputs
                } catch (error) {}
            }
        }
    }
    Process {
        id: actionProc
        property string successMessage: ""
        onExited: (code) => {
            root.refresh()
            root.toastRequested(code === 0 ? successMessage : "Action impossible")
        }
    }
    Process { id: configOpen; command: ["xdg-open", "/home/toubi/.config/waybar"] }

    Component.onCompleted: root.refresh()
}
