import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import "theme"

PanelWindow {
    id: root
    required property var modelData
    required property var hub
    screen: modelData
    readonly property var bar: hub.barFor(modelData.name)
    readonly property bool atTop: bar?.position === "top"
    readonly property var monitor: Hyprland.monitorFor(root.screen)
    readonly property int activeId: monitor?.activeWorkspace?.id ?? -1
    property var workspaceIds: []
    readonly property int activeIndex: workspaceIds.indexOf(activeId)
    visible: !!bar && (bar["modules-left"] || []).some(name => name.startsWith("custom/workspaces-"))
    implicitWidth: Math.max(32, workspaceIds.length * 6 + Math.max(0, workspaceIds.length - 1) * 14 + 16 + 6)
    implicitHeight: bar?.height ?? 34
    anchors.left: true
    anchors.top: atTop
    anchors.bottom: !atTop
    margins.left: Number(bar?.["margin-left"] ?? 8) + 12
    margins.top: atTop ? Number(bar?.["margin-top"] ?? 0) : 0
    margins.bottom: atTop ? 0 : Number(bar?.["margin-bottom"] ?? 8)
    exclusiveZone: -1
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace: "nord-violet-workspaces"
    Process {
        id: rules
        command: ["hyprctl", "workspacerules", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.workspaceIds = JSON.parse(text).filter(rule => rule.monitor === root.modelData.name)
                        .map(rule => Number(rule.workspaceString)).filter(id => Number.isInteger(id) && id > 0).sort((a,b) => a-b)
                } catch (error) { console.warn("Workspace ribbon: invalid rules", error) }
            }
        }
    }
    Component.onCompleted: rules.running = true
    Connections {
        target: Hyprland
        function onRawEvent(event) { if (event.name === "configreloaded" && !rules.running) rules.running = true }
    }
    // HTML option 13, Lucioles: 6px dots, 22px active pill, 14px gaps.
    Row {
        x: 3
        height: root.height
        spacing: 14
        Repeater {
            model: root.workspaceIds
            Item {
                id: workspace
                required property int modelData
                readonly property bool selected: root.activeId === modelData
                width: selected ? 22 : 6
                height: root.height
                Behavior on width {
                    NumberAnimation { duration: Theme.durationMedium > 0 ? Theme.durationMedium + 80 : 0; easing.type: Easing.OutCubic }
                }
                RectangularShadow {
                    anchors.fill: marker
                    radius: 3
                    blur: 9.6
                    color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.38)
                    opacity: workspace.selected ? 1 : 0
                    visible: opacity > 0
                    Behavior on opacity { NumberAnimation { duration: Theme.durationMedium } }
                }
                Rectangle {
                    id: marker
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: 6
                    radius: 3
                    color: workspace.selected ? Theme.accent : (clickArea.containsMouse ? "#afb5c5" : "#4d4669")
                    Behavior on color { ColorAnimation { duration: Theme.durationMedium } }
                }
                MouseArea {
                    id: clickArea
                    anchors.fill: parent
                    anchors.leftMargin: -7
                    anchors.rightMargin: -7
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.dispatch("workspace " + workspace.modelData)
                }
            }
        }
    }
}
