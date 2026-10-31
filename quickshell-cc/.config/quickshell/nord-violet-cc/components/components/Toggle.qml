import QtQuick
import "../theme"

// Switch on/off. 3 états volontairement simples :
//   OFF   -> gris neutre, pas d'accent
//   HOVER -> léger éclaircissement, toujours gris
//   ON    -> l'accent apparaît, seulement là
// Pas de gradient, pas de glow — la couleur indique l'état, point.
Rectangle {
    id: root
    property bool checked: false
    signal toggled(bool checked)

    implicitWidth: 40
    implicitHeight: 22
    radius: height / 2
    color: checked ? Theme.accentMuted : (hover.hovered ? Theme.surfaceHover : Theme.surface)
    border.width: 1
    border.color: checked ? Theme.accent : Theme.border

    Behavior on color { ColorAnimation { duration: Theme.durationFast } }

    Rectangle {
        x: root.checked ? root.width - width - 3 : 3
        anchors.verticalCenter: parent.verticalCenter
        width: 16
        height: 16
        radius: 8
        color: root.checked ? Theme.accent : Theme.textMuted

        Behavior on x { NumberAnimation { duration: Theme.durationFast; easing.type: Easing.OutQuad } }
        Behavior on color { ColorAnimation { duration: Theme.durationFast } }
    }

    HoverHandler { id: hover }

    TapHandler {
        onTapped: {
            root.checked = !root.checked
            root.toggled(root.checked)
        }
    }
}
