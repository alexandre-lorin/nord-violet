import QtQuick
import QtQuick.Layouts
import "../theme"

// v32 — row "label + choix en chips". Chaque entrée du modèle est
// { label, value } pour une chip texte, ou { label, color } pour une
// pastille de couleur (ex. les 4 presets d'accent de Colors.qml) — le
// delegate choisit automatiquement selon ce qui est présent.
Item {
    id: root

    property string label: ""
    property var model: []          // [{ label, value }] ou [{ label, color }]
    property var currentValue: null // comparé à .value OU .color selon le type d'entrée
    property bool showDivider: true
    signal selected(var value)      // renvoie soit .value soit .color de l'entrée choisie

    Layout.fillWidth: true
    implicitHeight: labelText.implicitHeight + 8 + chipsRow.implicitHeight + Theme.spacingMD * 2

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.spacingMD
        anchors.rightMargin: Theme.spacingMD
        anchors.topMargin: Theme.spacingMD
        anchors.bottomMargin: Theme.spacingMD
        spacing: 8

        Text {
            id: labelText
            Layout.fillWidth: true
            text: root.label
            color: Theme.textPrimary
            font.pixelSize: Theme.fontBody
            font.family: "JetBrains Mono"
            elide: Text.ElideRight
        }

        Flow {
            id: chipsRow
            Layout.fillWidth: true
            spacing: 8

            Repeater {
                model: root.model

                delegate: Rectangle {
                    id: chip
                    readonly property bool isColor: modelData.color !== undefined
                    readonly property var chipValue: isColor ? modelData.color : modelData.value
                    // v32 fix : `currentValue` peut être une vraie
                    // `color` QML (ex. Colors.accent) comparée à une
                    // chip dont la valeur est une string hex —
                    // `===` entre les deux ne matche pas de façon
                    // fiable (types différents), d'où Qt.colorEqual
                    // pour le cas couleur.
                    readonly property bool active: chip.isColor
                        ? Qt.colorEqual(root.currentValue, chip.chipValue)
                        : root.currentValue === chip.chipValue

                    radius: 2
                    color: active ? Theme.accentMuted : Theme.surfaceHover
                    border.width: 1
                    border.color: active ? Theme.accent : Theme.border
                    implicitHeight: 30
                    implicitWidth: chipRow.implicitWidth + 20

                    Behavior on color { ColorAnimation { duration: Theme.durationFast } }

                    RowLayout {
                        id: chipRow
                        anchors.centerIn: parent
                        spacing: 6

                        Rectangle {
                            visible: chip.isColor
                            width: 12
                            height: 12
                            radius: 6
                            color: chip.isColor ? modelData.color : "transparent"
                            border.width: 1
                            border.color: Theme.border
                        }

                        Text {
                            text: modelData.label
                            color: chip.active ? Theme.textPrimary : Theme.textSecondary
                            font.pixelSize: Theme.fontLabel
                            font.family: "JetBrains Mono"
                        }
                    }

                    TapHandler {
                        onTapped: root.selected(chip.chipValue)
                    }
                }
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
