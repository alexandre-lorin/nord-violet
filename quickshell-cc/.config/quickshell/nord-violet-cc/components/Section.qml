import QtQuick
import QtQuick.Layouts
import "../theme"

// Remplace "chaque élément = une carte avec bordure lumineuse et
// gradient". Un Section est UN groupe sobre : titre discret en haut,
// puis des lignes (SettingRow, ou n'importe quel Item) séparées par un
// simple filet — pas de carte dans la carte.
//
// Usage :
//   Section {
//       title: "Fenêtres"
//       SettingRow { label: "Border size"; value: "2 px" }
//       SettingRow { label: "Rounding"; value: "8 px"; last: true }
//   }
ColumnLayout {
    id: root
    spacing: 0

    property string title: ""
    default property alias content: inner.children

    Text {
        visible: root.title.length > 0
        text: root.title.toUpperCase()
        color: Theme.textMuted
        font.pixelSize: Theme.fontLabel
        font.family: "JetBrains Mono"
        font.letterSpacing: 1
        font.bold: true
        Layout.bottomMargin: Theme.spacingSM
    }

    Rectangle {
        Layout.fillWidth: true
        // Hauteur = somme des lignes enfants (elles sont des
        // ColumnLayout children ci-dessous, cette Rectangle sert
        // uniquement de fond + bordure de groupe).
        implicitHeight: inner.implicitHeight + Theme.spacingXS * 2
        radius: 2
        color: "#0e1015"
        border.width: 1
        border.color: Theme.border

        ColumnLayout {
            id: inner
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Theme.spacingXS
            spacing: 0
        }
    }
}
