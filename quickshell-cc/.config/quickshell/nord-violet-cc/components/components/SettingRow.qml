import QtQuick
import QtQuick.Layouts
import "../theme"

// Une ligne dans un Section : label à gauche, valeur/contrôle à droite,
// filet de séparation en bas (sauf sur la dernière ligne du groupe —
// mettre `last: true` sur celle-là). Pas de radius, pas de fond propre
// : c'est le Section parent qui porte la carte, cette ligne n'en est
// qu'un élément.
//
// Deux façons de l'utiliser :
//   SettingRow { label: "Border size"; value: "2 px" }             // texte simple
//   SettingRow {
//       label: "Blur"; last: true
//       control: Toggle { checked: true }                          // contrôle custom
//   }
Item {
    id: root
    Layout.fillWidth: true
    implicitHeight: 44

    property string label: ""
    property string value: ""
    property bool last: false
    // Slot pour un contrôle custom (Toggle, Slider...) à la place de
    // `value`. Si défini, prend le pas sur `value`.
    property alias control: controlSlot.children

    RowLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spacingMD

        Text {
            text: root.label
            color: Theme.textPrimary
            font.pixelSize: Theme.fontBody
            Layout.fillWidth: true
            elide: Text.ElideRight
        }

        Text {
            visible: root.value.length > 0 && controlSlot.children.length === 0
            text: root.value
            color: Theme.textSecondary
            font.pixelSize: Theme.fontBody
        }

        Item {
            id: controlSlot
            visible: children.length > 0
            implicitWidth: children.length > 0 ? children[0].implicitWidth : 0
            implicitHeight: children.length > 0 ? children[0].implicitHeight : 0
        }
    }

    // Filet de séparation ancré au bas de la ligne ENTIÈRE (pas un
    // enfant du RowLayout horizontal ci-dessus — sinon ça devient une
    // colonne de plus au lieu d'une bordure sous la ligne).
    Rectangle {
        visible: !root.last
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: Theme.border
    }
}
