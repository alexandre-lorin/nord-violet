import QtQuick
import QtQuick.Layouts
import "../theme"

// Tile compacte pour le Control Center (page Overview) — remplace les
// SettingRow "administratives" pour les réglages rapides. Contrairement à
// Toggle/SettingRow (pensés pour une longue liste de réglages détaillés),
// QuickTile est pensée pour 3-4 actions qu'on scanne d'un coup d'œil.
//
// 3 modes d'usage :
//   - INTERACTIF, état on/off : `interactive: true`, `active` reflète
//     l'état réel (binder depuis le parent, PAS depuis le tile lui-même —
//     même règle que Toggle, voir son fix). Le tile émet `tapped`, c'est
//     au parent de changer sa propriété source.
//       QuickTile { label: "Ne pas déranger"; value: active ? "Actif" : "Inactif"
//                   interactive: true; active: root.dndOn
//                   onTapped: root.setDnd(!root.dndOn) }
//   - INTERACTIF, action ponctuelle (pas d'état on/off, ex. "vider les
//     notifs") : `interactive: true`, `active: false` en permanence,
//     `momentary: true` fait flasher brièvement le point au tap pour
//     confirmer que l'action a bien été prise en compte.
//       QuickTile { label: "Notifications"; value: "Vider"; interactive: true
//                   momentary: true; onTapped: notifClear.running = true }
//   - LECTURE SEULE : `interactive: false` (défaut). Pas de TapHandler du
//     tout — règle explicite du projet : si ça ne contrôle rien, ça ne
//     doit pas avoir l'air cliquable.
//       QuickTile { label: "Bluetooth"; value: "Casque JBL"; active: true }
// v11 : le point d'état est remplacé par une icône colorée (glyphe
// Unicode simple, pas d'emoji couleur — mêmes glyphes que le mockup
// HTML de référence, garantis dispo dans n'importe quelle police,
// pas de dépendance à une Nerd Font). Déviation assumée de la règle
// "pas d'icône décorative séparée du reste du système" ci-dessus :
// demande explicite de l'utilisateur (v11), l'icône porte maintenant
// elle-même l'état (accent si actif, gris sinon) au lieu d'être
// purement décorative — donc ça reste dans l'esprit de la règle
// initiale, juste avec un vocabulaire visuel plus riche qu'un point.
Rectangle {
    id: root

    property string label: ""
    property string value: ""
    property string icon: ""
    property bool active: false
    property bool interactive: false
    property bool momentary: false
    property bool secondaryInteractive: false

    signal tapped()
    signal secondaryTapped()

    Layout.fillWidth: true
    Layout.preferredHeight: 70
    radius: 2
    color: root.active ? Theme.accentMuted : (hover.hovered && root.interactive ? Theme.surfaceHover : "#0e1015")
    border.width: 1
    border.color: root.active ? Theme.accent : Theme.border

    Behavior on color { ColorAnimation { duration: Theme.durationFast } }
    Behavior on border.color { ColorAnimation { duration: Theme.durationFast } }

    ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 8
        spacing: 3

        Icon {
            id: iconGlyph
            name: root.icon
            color: root.active ? Theme.accent : Theme.textMuted
            implicitWidth: 15
            implicitHeight: 15

            Behavior on color { ColorAnimation { duration: Theme.durationFast } }

            SequentialAnimation {
                id: flash
                running: false
                loops: 2
                ColorAnimation { target: iconGlyph; property: "color"; to: Theme.accent; duration: Theme.durationFast }
                ColorAnimation { target: iconGlyph; property: "color"; to: Theme.textMuted; duration: Theme.durationFast }
            }
        }

        Text {
            Layout.fillWidth: true
            text: root.label
            color: Theme.textPrimary
            font.pixelSize: Theme.fontBody
            font.family: "JetBrains Mono"
            font.bold: true
            wrapMode: Text.WordWrap
            maximumLineCount: 1
            elide: Text.ElideRight
        }

        Text {
            Layout.fillWidth: true
            text: root.value
            color: root.active ? Theme.textPrimary : Theme.textMuted
            font.pixelSize: Theme.fontLabel
            font.family: "JetBrains Mono"
            elide: Text.ElideRight
        }
    }

    HoverHandler { id: hover; enabled: root.interactive }
    TapHandler {
        enabled: root.secondaryInteractive
        acceptedButtons: Qt.RightButton
        onTapped: root.secondaryTapped()
    }

    TapHandler {
        enabled: root.interactive
        onTapped: {
            if (root.momentary) flash.start()
            root.tapped()
        }
    }
}
