import QtQuick
import QtQuick.Layouts
import "../theme"

// v32 — row "label + valeur + slider", même langage visuel que le
// slider de volume déjà en prod dans AudioFlyout.qml (piste + poignée,
// pas de dégradé/glow — règle du projet), juste sorti en composant
// réutilisable avec min/max/step génériques au lieu d'être câblé en dur
// sur le volume.
Item {
    id: root

    property string label: ""
    property real value: 0      // valeur courante
    property real from: 0
    property real to: 100
    property string unit: "%"
    property bool showDivider: true
    signal moved(real value)    // émis en continu pendant le drag/molette
    function moveTo(next) { root.moved(Math.max(root.from, Math.min(root.to, next))) }

    readonly property real clamped: to > from ? Math.max(0, Math.min(1, (value - from) / (to - from))) : 0

    Layout.fillWidth: true
    implicitHeight: 68
    opacity: enabled ? 1 : 0.45
    activeFocusOnTab: true
    Keys.onLeftPressed: event => { moveTo(value - 1); event.accepted = true }
    Keys.onRightPressed: event => { moveTo(value + 1); event.accepted = true }
    Keys.onPressed: event => {
        if (event.key === Qt.Key_Home) { moveTo(from); event.accepted = true }
        else if (event.key === Qt.Key_End) { moveTo(to); event.accepted = true }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.spacingMD
        anchors.rightMargin: Theme.spacingMD
        anchors.topMargin: Theme.spacingSM
        anchors.bottomMargin: 12
        spacing: 6

        RowLayout {
            Layout.fillWidth: true
            Text {
                Layout.fillWidth: true
                text: root.label
                color: Theme.textPrimary
                font.pixelSize: Theme.fontBody
                font.family: "JetBrains Mono"
                elide: Text.ElideRight
            }
            Text {
                text: Math.round(root.value) + root.unit
                color: Theme.textMuted
                font.pixelSize: Theme.fontLabel
                font.family: "JetBrains Mono"
            }
        }

        Item {
            id: track
            Layout.fillWidth: true
            implicitHeight: 20
            Layout.minimumHeight: 20
            Layout.maximumHeight: 20

            function setFromX(x) {
                var pct = Math.max(0, Math.min(1, x / track.width))
                root.moveTo(root.from + pct * (root.to - root.from))
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                height: 6
                radius: 1
                color: Theme.surfaceHover

                Rectangle {
                    width: parent.width * root.clamped
                    height: parent.height
                    radius: 1
                    color: Theme.accent
                }
            }

            Rectangle {
                width: 16
                height: 16
                radius: 2
                color: Theme.textPrimary
                border.width: 2
                border.color: Theme.accent
                anchors.verticalCenter: parent.verticalCenter
                x: root.clamped * (track.width - width)
            }

            MouseArea {
                anchors.fill: parent
                onPressed: (mouse) => { root.forceActiveFocus(); track.setFromX(mouse.x) }
                onPositionChanged: (mouse) => { if (pressed) track.setFromX(mouse.x) }
            }

            WheelHandler {
                onWheel: (event) => {
                    if (event.angleDelta.y === 0) return
                    var step = 1
                    root.moveTo(root.value + (event.angleDelta.y > 0 ? step : -step))
                    event.accepted = true
                }
            }
            Rectangle {
                anchors.fill: parent
                color: "transparent"
                border.width: root.activeFocus ? 1 : 0
                border.color: Theme.accent
                radius: 2
            }
        }
    }

    Rectangle {
        visible: root.showDivider
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: Theme.spacingMD
        height: 1
        color: Theme.border
    }
}
