import QtQuick
import QtQuick.Layouts
import "../theme"

Rectangle {
    id: root
    default property alias content: contentRow.data
    Layout.fillWidth: true
    implicitHeight: Math.max(96, contentRow.implicitHeight + 32)
    radius: 2
    color: "#0e1015"
    border.width: 1
    border.color: Theme.border

    RowLayout {
        id: contentRow
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 16
    }
}
