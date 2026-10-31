import QtQuick
import QtQuick.Layouts
import "../theme"

// v32 — factorisé depuis le pattern répété tel quel dans AudioFlyout.qml
// ("APPAREILS"), WifiFlyout.qml ("RÉSEAUX") et OverviewPage.qml : un
// Text majuscule/espacé/muted, toujours les mêmes valeurs. Un seul
// endroit à modifier si ce style doit changer un jour. Pas de
// comportement nouveau, juste du DRY.
Text {
    id: root

    property bool first: false

    Layout.fillWidth: true
    Layout.topMargin: first ? 0 : 14
    Layout.bottomMargin: 0

    // Appelant responsable de la casse (majuscules) — comme dans le
    // code existant ("APPAREILS", "RÉSEAUX"), pas d'auto-uppercase ici
    // pour rester simple et éviter un binding sur soi-même.
    color: Theme.textMuted
    font.pixelSize: 10
    font.family: "JetBrains Mono"
    font.letterSpacing: 0.6
    font.bold: true
}
