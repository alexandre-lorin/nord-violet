import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import "../theme"
import "../components"

ColumnLayout {
    id: root
    spacing: 8
    signal toastRequested(string message)

    function openMain(query) {
        if (mainLauncher.running) return
        mainLauncher.command = ["/home/toubi/.local/bin/omni-launcher", "--search", query || ""]
        mainLauncher.running = true
        root.toastRequested("Omni ouvert")
    }

    Process { id: emojiLauncher; command: ["/home/toubi/.local/bin/omni-emoji"] }
    Process { id: clipboardLauncher; command: ["/home/toubi/.local/bin/omni-clipboard"] }
    Process { id: windowsLauncher; command: ["/home/toubi/.local/bin/omni-windows"] }
    Process { id: mainLauncher; command: ["/home/toubi/.local/bin/omni-launcher"] }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: Math.max(104, searchContent.implicitHeight + 32)
        radius: 2
        color: Theme.surface
        border.width: 1
        border.color: Theme.border
        ColumnLayout {
            id: searchContent
            anchors.fill: parent; anchors.margins: 16; spacing: 8
            Text { text: "[ OMNI / RECHERCHE ]"; color: Theme.accent; font.family: "JetBrains Mono"; font.pixelSize: 10 }
            TextField {
                id: omniSearch
                Layout.fillWidth: true; Layout.preferredHeight: 42
                placeholderText: "Application ou action… Entrée pour rechercher"
                placeholderTextColor: Theme.textMuted; color: Theme.textPrimary; font.pixelSize: Theme.fontBody
                font.family: "JetBrains Mono"
                background: Rectangle { radius: Theme.radiusSmall; color: Theme.background; border.width: 1; border.color: parent.activeFocus ? Theme.accent : Theme.border }
                onAccepted: {
                    root.openMain(text.trim())
                    text = ""
                }
            }
        }
    }

    SectionHeader { text: "RECHERCHE UNIFIÉE" }
    SettingsCard {
        RowButton {
            label: "Applications et actions"
            value: "Actif · Super+Espace"
            showChevron: true
            onClicked: {
                root.openMain("")
            }
        }
        RowButton { label: "Réglages"; value: "Actif dans Omni" }
        RowButton {
            label: "Emoji"
            value: "Actif · Super+N"
            showChevron: true
            onClicked: {
                emojiLauncher.running = true
                root.toastRequested("Fournisseur Emoji ouvert")
            }
        }
        RowButton {
            label: "Presse-papiers"
            value: "Actif · Super+V"
            showChevron: true
            onClicked: {
                clipboardLauncher.running = true
                root.toastRequested("Historique du presse-papiers ouvert")
            }
        }
        RowButton {
            label: "Fenêtres ouvertes"
            value: "Actif · Super+W"
            showChevron: true
            showDivider: false
            onClicked: {
                windowsLauncher.running = true
                root.toastRequested("Sélecteur de fenêtres ouvert")
            }
        }
    }
    Text { Layout.fillWidth: true; text: "Emoji, presse-papiers et fenêtres sont actifs. Omni couvre maintenant les trois actions rapides du workflow."; color: Theme.textMuted; font.pixelSize: Theme.fontLabel; wrapMode: Text.WordWrap }
    Item { Layout.fillHeight: true }
}
