import QtQuick
import "../theme"

// Une touche façon "keycap" — pour composer un raccourci en petites
// pastilles (ex: [SUPER] [Q]) plutôt qu'un seul bloc de texte
// "SUPER + Q". Usage typique dans un Row : Keycap { text: "SUPER" };
// Keycap { text: "Q" }.
Rectangle {
    id: root
    property string text: ""

    implicitWidth: Math.max(26, label.implicitWidth + 16)
    implicitHeight: 24
    radius: Theme.radiusSmall
    color: Theme.surfaceHover
    border.width: 1
    border.color: Theme.border

    Text {
        id: label
        anchors.centerIn: parent
        text: root.text
        color: Theme.textSecondary
        font.pixelSize: Theme.fontLabel
        font.bold: true
        font.letterSpacing: 0.5
    }
}
