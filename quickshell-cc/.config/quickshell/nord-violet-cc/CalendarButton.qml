import QtQuick
import "theme"

Rectangle {
    id: root
    property string text: ""
    property string description: text
    signal clicked()
    implicitWidth: 28
    implicitHeight: 28
    radius: Theme.radiusSmall
    color: mouse.containsMouse || activeFocus ? Theme.surfaceHover : "transparent"
    border.width: activeFocus ? 1 : 0
    border.color: Theme.accent
    activeFocusOnTab: true
    Accessible.role: Accessible.Button
    Accessible.name: description
    Accessible.onPressAction: clicked()
    Keys.onReturnPressed: clicked()
    Keys.onSpacePressed: clicked()
    Text {
        anchors.centerIn: parent
        text: root.text
        font.family: "Inter"
        font.pixelSize: Theme.fontBody
        color: Theme.textSecondary
    }
    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
