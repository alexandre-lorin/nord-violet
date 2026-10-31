import QtQuick
import QtQuick.Layouts
import "../theme"

// v32 — row "label (+ sous-texte) + Toggle", pensée pour vivre à
// l'intérieur d'un SettingsCard. Réutilise le composant `Toggle`
// existant du projet (déjà utilisé tel quel dans WifiFlyout.qml :
// `Toggle { checked: root.wifiEnabled; onToggled: (state) => ... }`) —
// PAS un nouveau composant Toggle, juste un habillage row autour de
// celui qui existe déjà. Si sa signature diffère de ce qu'on suppose
// ici (`checked` + `onToggled(state)`), c'est le seul endroit à
// corriger.
Item {
    id: root

    property string label: ""
    property string subtext: ""
    property bool checked: false
    property bool showDivider: true
    signal toggled(bool state)

    Layout.fillWidth: true
    implicitHeight: 44
    opacity: enabled ? 1 : 0.45

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.spacingMD
        anchors.rightMargin: Theme.spacingMD
        spacing: Theme.spacingSM

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1

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

        Toggle {
            checked: root.checked
            onToggled: (state) => root.toggled(state)
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

    // Toute la row est cliquable, pas juste le switch — plus facile à
    // toucher/cliquer.
    MouseArea {
        anchors.fill: parent
        onClicked: root.toggled(!root.checked)
    }
}
