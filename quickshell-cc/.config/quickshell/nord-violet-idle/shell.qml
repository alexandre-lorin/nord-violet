import QtQuick
import Quickshell
import Quickshell.Io

// FIX #2 (retour utilisateur : bloqué sur l'écran 1, le keybind
// "suivait" le clavier au lieu de cibler le bon moniteur) : retour au
// layer-shell (PanelWindow) pour CETTE page, à l'inverse du choix fait
// sur nord-violet-cc. Contrairement au fullscreen "par hint" d'une
// Window classique (négocié avec le compositeur, Hyprland choisissait
// le moniteur actif au lieu du moniteur ciblé), un layer-surface DOIT
// déclarer son output dès sa création (protocole wlr-layer-shell) —
// Hyprland ne peut pas se tromper. Variants + Quickshell.screens est
// le pattern standard Quickshell pour une surface par écran.
ShellRoot {
    id: root
    property bool idleVisible: false
    property color accent: "#9b7cff"
    onIdleVisibleChanged: if (idleVisible) accentRead.running = true

    Process {
        id: accentRead
        command: ["cat", "/home/toubi/.config/quickshell/nord-violet-cc/state/accent"]
        stdout: StdioCollector {
            onStreamFinished: {
                var value = text.trim()
                if (/^#[0-9a-fA-F]{6}$/.test(value)) root.accent = value
            }
        }
    }

    Variants {
        model: Quickshell.screens

        IdleScreen {
            visible: root.idleVisible
            rainColor: root.accent
            onCloseRequested: root.idleVisible = false
        }
    }

    IpcHandler {
        target: "idle"

        function toggle(): void {
            root.idleVisible = !root.idleVisible
        }

        function open(): void {
            root.idleVisible = true
        }

        function close(): void {
            root.idleVisible = false
        }
    }
}
