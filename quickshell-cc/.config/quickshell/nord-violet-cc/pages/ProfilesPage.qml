import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../theme"
import "../components"

ColumnLayout {
    id: root
    spacing: 8
    property string selectedProfile: "custom"
    property bool applying: profileApply.running
    property bool focusActive: false
    property bool focusPaused: false
    property bool pollingActive: true
    onPollingActiveChanged: if (pollingActive) refreshFocus()
    property int focusRemaining: 0
    readonly property string scriptPath: "/home/toubi/.config/quickshell/nord-violet-cc/scripts/profilectl.sh"
    readonly property string focusScriptPath: "/home/toubi/.config/quickshell/nord-violet-cc/scripts/focusctl.sh"
    signal toastRequested(string message)

    function applyProfile(key) {
        if (applying) return
        profileApply.command = [scriptPath, key]
        profileApply.running = true
    }

    function refreshFocus() { if (!focusRead.running) focusRead.running = true }

    function setFocus(minutes) {
        focusAction("start", minutes)
    }

    function focusAction(action, minutes) {
        if (focusWrite.running) return
        focusWrite.command = [focusScriptPath, action, String(minutes || 50)]
        focusWrite.running = true
    }

    function focusLabel() {
        if (!focusActive && !focusPaused) return "Inactive"
        return (focusPaused ? "Pause · " : "") + Math.floor(focusRemaining / 60).toString().padStart(2, "0") + ":" + (focusRemaining % 60).toString().padStart(2, "0")
    }

    SectionHeader { text: "PROFILS DE CONTEXTE"; first: true }
    GridLayout {
        Layout.fillWidth: true
        columns: width >= 760 ? 4 : 2
        columnSpacing: Theme.spacingSM
        rowSpacing: Theme.spacingSM
        Repeater {
            model: [
                { key: "work", name: "Normal / travail", icon: "◫", detail: "Équilibré · 75 % · notifications" },
                { key: "mobile", name: "Nomade", icon: "◇", detail: "Économie · 50 % · autonomie" },
                { key: "game", name: "Jeu", icon: "▶", detail: "Performance · DND · VRR" },
                { key: "night", name: "Nuit", icon: "☾", detail: "Économie · 25 % · DND" }
            ]
            delegate: Rectangle {
                required property var modelData
                Layout.fillWidth: true; Layout.preferredHeight: 120
                radius: 2
                color: root.selectedProfile === modelData.key ? Theme.accentMuted : Theme.surface
                border.width: 1
                border.color: root.selectedProfile === modelData.key ? Theme.accent : Theme.border
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: Theme.spacingMD; spacing: 7
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: modelData.icon; color: Theme.accent; font.pixelSize: 18 }
                        Item { Layout.fillWidth: true }
                        Text {
                            visible: root.selectedProfile === modelData.key
                            text: "ACTIF"
                            color: Theme.accent
                            font.pixelSize: 9
                            font.bold: true
                        }
                    }
                    Item { Layout.fillHeight: true }
                    Text { text: modelData.name; color: Theme.textPrimary; font.family: "JetBrains Mono"; font.pixelSize: Theme.fontBody; font.bold: true }
                    Text { Layout.fillWidth: true; text: modelData.detail; color: Theme.textMuted; font.family: "JetBrains Mono"; font.pixelSize: 10; wrapMode: Text.WordWrap }
                }
                opacity: root.applying ? 0.65 : 1
                TapHandler { enabled: !root.applying; onTapped: root.applyProfile(modelData.key) }
            }
        }
    }

    SectionHeader { text: "EFFETS DU PROFIL" }
    SettingsCard {
        RowButton { label: "Énergie"; value: "power-profiles-daemon" }
        RowButton { label: "Affichage"; value: "Luminosité + VRR" }
        RowButton { label: "Concentration"; value: "Mode DND Mako"; showDivider: false }
    }
    SectionHeader { text: "SESSION FOCUS / MINUTEUR + NE PAS DÉRANGER" }
    Text {
        Layout.fillWidth: true
        text: "25 ou 50 minutes sans notifications. La pause et l'arrêt restaurent le mode précédent ; reprendre active de nouveau Ne pas déranger. Le compteur apparaît dans Waybar."
        color: Theme.textMuted
        font.family: "JetBrains Mono"
        font.pixelSize: 11
        wrapMode: Text.WordWrap
    }
    SettingsCard {
        RowButton {
            label: root.focusActive ? "Mettre en pause" : root.focusPaused ? "Reprendre la session" : "Focus court"
            value: (root.focusActive || root.focusPaused) ? root.focusLabel() : "25 minutes"
            enabled: !focusWrite.running
            showChevron: true
            onClicked: (root.focusActive || root.focusPaused) ? root.focusAction("pause-toggle") : root.setFocus(25)
        }
        RowButton {
            label: (root.focusActive || root.focusPaused) ? "Arrêter la session" : "Focus profond"
            value: (root.focusActive || root.focusPaused) ? "Restaurer les notifications" : "50 minutes"
            enabled: !focusWrite.running
            showChevron: true
            showDivider: false
            onClicked: (root.focusActive || root.focusPaused) ? root.focusAction("cancel") : root.setFocus(50)
        }
    }
    Text { Layout.fillWidth: true; text: root.applying ? "Application du profil…" : "Un clic applique immédiatement les réglages. La disposition des écrans reste volontairement inchangée."; color: Theme.textMuted; font.pixelSize: Theme.fontLabel; wrapMode: Text.WordWrap }
    Item { Layout.fillHeight: true }

    Process {
        id: profileRead
        command: [root.scriptPath, "status"]
        stdout: StdioCollector {
            onStreamFinished: root.selectedProfile = text.trim()
        }
    }

    Process {
        id: profileApply
        stdout: StdioCollector {
            onStreamFinished: {
                var parts = text.trim().split("|")
                if (parts.length < 2) return
                root.selectedProfile = parts[0]
                root.toastRequested(parts.slice(1).join("|"))
            }
        }
    }

    Process {
        id: focusRead
        command: [root.focusScriptPath, "status"]
        stdout: StdioCollector {
            onStreamFinished: {
                var parts = text.trim().split("|")
                root.focusActive = parts[0] === "active"
                root.focusPaused = parts[0] === "paused"
                root.focusRemaining = parts.length > 1 ? parseInt(parts[1]) || 0 : 0
            }
        }
    }
    Process {
        id: focusWrite
        onExited: (exitCode) => {
            root.refreshFocus()
            root.toastRequested(exitCode === 0 ? "Session Focus mise à jour" : "Impossible de modifier la session Focus")
        }
    }
    Timer { interval: 1000; running: root.pollingActive; repeat: true; onTriggered: root.refreshFocus() }

    Component.onCompleted: {
        profileRead.running = true
        focusRead.running = true
    }
}
