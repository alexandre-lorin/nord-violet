import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../theme"

// v32 — row générique "label [+ valeur à droite] [+ chevron]", pour
// tout ce qui n'est ni un toggle ni un slider : une info en lecture
// seule (ex. "Version — 0.31"), une action (ex. "Ouvrir le dossier de
// config"), ou une entrée qui ouvrirait une sous-page plus tard.
// `active`/`onClicked` optionnels — sans handler connecté, c'est juste
// une ligne d'info avec un hover neutre.
Item {
    id: root

    property string label: ""
    property string value: ""
    property string subtext: ""
    property bool showChevron: false
    property bool showDivider: true
    signal clicked()

    Layout.fillWidth: true
    implicitHeight: subtext.length > 0 ? 58 : 40
    opacity: enabled ? 1 : 0.45

    Rectangle {
        anchors.fill: parent
        color: rowHover.hovered ? Theme.surfaceHover : "transparent"
        Behavior on color { ColorAnimation { duration: Theme.durationFast } }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.spacingMD
        anchors.rightMargin: Theme.spacingMD
        spacing: Theme.spacingSM

        ColumnLayout {
            Layout.fillWidth: true
            Layout.minimumWidth: 60
            spacing: 4
            Text {
                Layout.fillWidth: true
                text: root.label
                color: Theme.textPrimary
                font.pixelSize: Theme.fontBody
                font.family: "JetBrains Mono"
                elide: Text.ElideRight
            }
            Text {
                Layout.fillWidth: true
                visible: root.subtext.length > 0
                text: root.subtext
                color: Theme.textMuted
                font.pixelSize: Theme.fontLabel
                font.family: "JetBrains Mono"
                elide: Text.ElideRight
            }
        }

        Text {
            visible: root.value.length > 0
            Layout.maximumWidth: Math.max(60, root.width * 0.42)
            text: root.value
            color: Theme.textMuted
            font.pixelSize: Theme.fontLabel
            font.family: "JetBrains Mono"
            elide: Text.ElideRight
        }

        Text {
            visible: root.showChevron
            text: "›"
            color: Theme.textMuted
            font.pixelSize: Theme.fontBody
            font.family: "JetBrains Mono"
            font.bold: true
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

    HoverHandler { id: rowHover }
    TapHandler { onTapped: root.clicked() }
    ToolTip.visible: rowHover.hovered && (root.value.length > 0 || root.subtext.length > 0)
    ToolTip.delay: 800
    ToolTip.text: root.label + (root.subtext.length ? "\n" + root.subtext : "") + (root.value.length ? "\n" + root.value : "")
}
