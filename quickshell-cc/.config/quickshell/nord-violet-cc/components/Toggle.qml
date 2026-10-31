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
    radius: 2
    color: checked ? Theme.accentMuted : (hover.hovered ? Theme.surfaceHover : Theme.surface)
    border.width: 1
    border.color: checked ? Theme.accent : Theme.border

    Behavior on color { ColorAnimation { duration: Theme.durationFast } }

    Rectangle {
        x: root.checked ? root.width - width - 3 : 3
        anchors.verticalCenter: parent.verticalCenter
        width: 16
        height: 16
        radius: 1
        color: root.checked ? Theme.accent : Theme.textMuted

        Behavior on x { NumberAnimation { duration: Theme.durationFast; easing.type: Easing.OutQuad } }
        Behavior on color { ColorAnimation { duration: Theme.durationFast } }
    }

    HoverHandler { id: hover }

    // FIX (bug DND confirmé) : ce TapHandler faisait auparavant
    // `root.checked = !root.checked` AVANT d'émettre `toggled`. Une
    // assignation impérative sur une propriété QML casse tout binding
    // externe posé dessus (ex: `checked: root.dndOn` dans
    // OverviewPage.qml) — après le premier clic, `checked` devient une
    // valeur locale figée, plus jamais reliée à `root.dndOn`, donc le
    // toggle semble "mort" (visuellement figé ou désynchronisé de
    // l'état réel mako/hyprctl). Le Toggle ne décide plus de son propre
    // état : il se contente de signaler l'intention. C'est au binding
    // externe (`checked: ...`) de refléter la valeur, une fois que le
    // parent a mis à jour sa propriété source dans `onToggled`.
    TapHandler {
        onTapped: root.toggled(!root.checked)
    }
}
