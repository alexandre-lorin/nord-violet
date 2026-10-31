import QtQuick
import QtQuick.Layouts
import "../theme"

// Placeholder générique — utilisé par les sections pas encore construites
// (Apparence, Écrans, Son, Connexions, Système). Sans ce fichier,
// ControlCenter.qml référençait Pages.AppearancePage / DisplayPage /
// AudioPage / ConnectionsPage / SystemPage qui n'existent pas dans ce
// zip : cliquer sur une de ces 5 entrées de la sidebar plantait le
// panneau (fichier QML introuvable) au lieu d'afficher quoi que ce soit.
//
// Usage : Pages.ComingSoonPage { pageTitle: "Apparence" }
ColumnLayout {
    id: root
    property string pageTitle: ""

    Item { Layout.fillHeight: true; Layout.preferredHeight: 1 }

    ColumnLayout {
        Layout.alignment: Qt.AlignHCenter
        spacing: Theme.spacingXS

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "🚧"
            font.pixelSize: 28
        }
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: root.pageTitle + " — bientôt disponible"
            color: Theme.textSecondary
            font.pixelSize: Theme.fontBody
        }
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "Cette section n'est pas encore branchée."
            color: Theme.textMuted
            font.pixelSize: Theme.fontLabel
        }
    }

    Item { Layout.fillHeight: true; Layout.preferredHeight: 1 }
}
