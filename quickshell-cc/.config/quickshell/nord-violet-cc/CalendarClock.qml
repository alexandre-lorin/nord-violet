import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "theme"

// A transparent input surface over Waybar's native clock. Waybar keeps
// rendering the time; Qt provides the two-column tooltip GTK cannot lay out.
// Geometry follows Waybar's watched config, including top/bottom changes.
PanelWindow {
    id: root
    required property var modelData
    required property var hub
    screen: modelData
    readonly property var bar: hub.barFor(modelData.name)
    readonly property bool atTop: bar?.position === "top"
    readonly property int edgeMargin: bar ? Number(bar[atTop ? "margin-top" : "margin-bottom"] ?? 0) : 8
    readonly property int popupMargin: edgeMargin + implicitHeight + 12
    visible: !!bar && (bar["modules-center"] || []).includes("clock")
    implicitWidth: 66
    implicitHeight: bar?.height ?? 34
    anchors.bottom: !atTop
    anchors.top: atTop
    margins.bottom: atTop ? 0 : edgeMargin
    margins.top: atTop ? edgeMargin : 0
    exclusiveZone: -1
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace: "nord-violet-clock-input"
    readonly property bool opened: visible && hub.activeScreen === modelData.name
    property bool hovered: false
    property date now: new Date()
    readonly property var locale: Qt.locale("fr_FR")

    function close() { hub.activeScreen = "" }
    onOpenedChanged: {
        hovered = false
        hoverDelay.stop()
        if (opened) {
            card.reset()
            Qt.callLater(() => { if (root.opened) { card.forceActiveFocus(); grab.active = true } })
        } else grab.active = false
    }
    Timer {
        id: hoverDelay
        interval: 280
        onTriggered: { root.now = new Date(); root.hovered = true }
    }
    Timer {
        interval: 1000; repeat: true; running: root.hovered || root.opened
        onTriggered: { root.now = new Date(); card.today = root.now }
    }
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onEntered: { if (!root.opened) hoverDelay.restart() }
        onExited: { hoverDelay.stop(); root.hovered = false }
        onClicked: root.hub.activeScreen = root.opened ? "" : root.modelData.name
        // Keep rapid repeated right-clicks equivalent to ordinary toggles.
        onDoubleClicked: mouse => { mouse.accepted = false }
    }
    PanelWindow {
        id: tooltip
        screen: root.screen
        visible: root.visible && root.hovered && !root.opened
        implicitWidth: 220; implicitHeight: 74
        anchors.bottom: !root.atTop; anchors.top: root.atTop
        margins.bottom: root.atTop ? 0 : root.popupMargin
        margins.top: root.atTop ? root.popupMargin : 0
        exclusiveZone: -1
        color: "transparent"
        mask: Region {}
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace: "nord-violet-date"
        Rectangle {
            anchors.fill: parent
            color: Theme.surface; radius: Theme.radiusMedium
            border.color: Theme.border
            Text {
                x: 18; anchors.verticalCenter: parent.verticalCenter
                text: root.now.getDate().toString().padStart(2, "0")
                font.family: "Inter"; font.pixelSize: 34; font.weight: Font.DemiBold
                color: Theme.textPrimary
            }
            Column {
                x: 78; anchors.verticalCenter: parent.verticalCenter; spacing: 5
                Text {
                    text: {
                        const value = root.now.toLocaleDateString(root.locale, "dddd")
                        return value.charAt(0).toUpperCase() + value.slice(1)
                    }
                    color: Theme.textPrimary; font.family: "Inter"; font.pixelSize: 12
                }
                Text {
                    text: root.now.toLocaleDateString(root.locale, "MMMM yyyy")
                    color: Theme.textMuted; font.family: "Inter"; font.pixelSize: 11
                }
            }
        }
    }
    PanelWindow {
        id: calendar
        screen: root.screen
        visible: root.opened
        implicitWidth: card.implicitWidth; implicitHeight: card.implicitHeight
        anchors.bottom: !root.atTop; anchors.top: root.atTop
        margins.bottom: root.atTop ? 0 : root.popupMargin
        margins.top: root.atTop ? root.popupMargin : 0
        exclusiveZone: -1
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        WlrLayershell.namespace: "nord-violet-calendar"
        CalendarCard {
            id: card
            anchors.fill: parent
            onCloseRequested: root.close()
        }
    }
    HyprlandFocusGrab {
        id: grab
        windows: [calendar]
        onCleared: root.close()
    }
}
