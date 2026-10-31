import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import Quickshell
import Quickshell.Io
import "theme"
import "components"

// v30 — OSD volume/luminosité. Apparaît brièvement quand le volume ou
// la luminosité change (molette waybar OU touches XF86 clavier via
// hypr/keybinds.conf + scripts/osd-trigger.sh), se referme seule après
// un délai — pas d'interaction, pas de clic, pas de focus requis.
//
// Même squelette que AudioFlyout.qml/WifiFlyout.qml (v27+, special
// workspace + _mapped/_revealed/_positioning) puisque ce pattern est
// le seul confirmé ne pas "sauter" à l'écran dans ce projet. Différence
// principale : fermeture par Timer (auto-hide) au lieu de blur — donc
// PAS de focusItem/forceActiveFocus() du tout, ce qui évite par
// construction toute la classe de bug "focus reste coincé" rencontrée
// sur les flyouts (v29). JAMAIS TESTÉ EN LIVE — écrit sans accès PC.
Window {
    id: flyout
    width: 390
    height: 92
    color: "transparent"
    visible: false
    title: "Nord Violet OSD"
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.Tool

    property string mode: "volume" // "volume" | "brightness"
    property real pct: 0
    property bool muted: false

    property bool _revealed: false
    property bool _positioning: false
    property bool _mapped: false
    property int _targetMonitorId: -1

    Rectangle {
        id: card
        anchors.fill: parent
        radius: Theme.radiusSmall
        color: Theme.background
        border.width: 1
        border.color: Theme.border
        opacity: 0
        Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 9

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                AudioIcon {
                    visible: flyout.mode === "volume"
                    width: 16
                    height: 16
                    pct: flyout.muted ? 0 : flyout.pct
                    color: Theme.accent
                }
                Icon {
                    visible: flyout.mode === "brightness"
                    name: "brightness"
                    width: 16
                    height: 16
                    color: Theme.accent
                }
                Text {
                    text: flyout.mode === "volume"
                          ? (flyout.muted ? "MUET" : "VOLUME")
                          : "LUMINOSITÉ"
                    color: Theme.textSecondary
                    font.pixelSize: Theme.fontLabel
                    font.family: "JetBrains Mono"
                    font.bold: true
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: Math.round(flyout.pct) + "%"
                    color: Theme.textPrimary
                    font.pixelSize: 18
                    font.family: "JetBrains Mono"
                    font.bold: true
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 3
                Repeater {
                    model: 20
                    Rectangle {
                        required property int index
                        Layout.fillWidth: true
                        Layout.preferredHeight: 7
                        radius: 1
                        color: index < Math.ceil(flyout.pct / 5)
                               ? (flyout.muted ? Theme.textMuted : Theme.accent)
                               : Theme.surfaceHover
                    }
                }
            }
        }
    }

    // -- Positionnement (identique en structure à AudioFlyout.qml) ------
    Process {
        id: clientsProc
        command: ["hyprctl", "clients", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                var list
                try { list = JSON.parse(text) } catch (e) { list = [] }
                var found = null
                for (var i = 0; i < list.length; i++) {
                    if (list[i].title === "Nord Violet OSD") { found = list[i]; break }
                }
                if (!found) {
                    console.log("[osd] fenêtre pas encore mappée")
                    positionRetry.start()
                    return
                }
                flyout._targetMonitorId = found.monitor
                monitorsProc.running = true
            }
        }
    }

    Process {
        id: monitorsProc
        command: ["hyprctl", "monitors", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                var mons
                try { mons = JSON.parse(text) } catch (e) { mons = [] }
                var mon = null
                for (var i = 0; i < mons.length; i++) {
                    if (mons[i].id === flyout._targetMonitorId) { mon = mons[i]; break }
                }
                if (!mon && mons.length > 0) mon = mons[0]
                if (!mon) { flyout._positioning = false; return }

                var reservedBottom = (mon.reserved && mon.reserved.length === 4) ? mon.reserved[3] : 0
                var gap = 14
                // Centré horizontalement, ancré au-dessus de waybar —
                // position générique (macOS-like), jamais confirmée
                // contre la vraie disposition de l'écran de l'utilisateur.
                var x = Math.round(mon.x + mon.width / 2 - flyout.width / 2)
                var y = Math.round(mon.y + mon.height - reservedBottom - flyout.height - gap)

                var arg = "exact " + x + " " + y + ",title:^(Nord Violet OSD)$"
                console.log("[osd] moniteur", mon.name, "-> dispatch", arg)
                moveProc.command = ["hyprctl", "dispatch", "movewindowpixel", arg]
                moveProc.running = true
                flyout._positioning = false
                flyout._mapped = true
                flyout.reveal()
            }
        }
    }

    Process {
        id: moveProc
        stdout: StdioCollector { onStreamFinished: if (text.trim().length > 0) console.log("[osd] move stdout:", text.trim()) }
        stderr: StdioCollector { onStreamFinished: if (text.trim().length > 0) console.log("[osd] move stderr:", text.trim()) }
    }

    Timer { id: positionRetry; interval: 40; onTriggered: clientsProc.running = true }

    Process {
        id: toggleSpecialProc
        command: ["hyprctl", "dispatch", "togglespecialworkspace", "nvosd"]
        stderr: StdioCollector { onStreamFinished: if (text.trim().length > 0) console.log("[osd] togglespecial stderr:", text.trim()) }
    }

    function reveal() {
        card.opacity = 1
        toggleSpecialProc.running = true
        _revealed = true
        autoHide.restart()
    }

    function hideFlyout() {
        if (!_revealed) return
        card.opacity = 0
        toggleSpecialProc.running = true
        _revealed = false
    }

    Timer {
        id: autoHide
        interval: 1400
        onTriggered: flyout.hideFlyout()
    }

    // -- API appelée depuis shell.qml (IpcHandler `osd`) -----------------
    function show(newMode, newPct, isMuted) {
        // La luminosité est contrôlée sans popup à la demande de Toubi.
        if (newMode === "brightness") return
        console.log("[osd] show() —", newMode, newPct, "_mapped:", _mapped, "_revealed:", _revealed)
        mode = newMode
        pct = newPct
        muted = !!isMuted
        visible = true

        if (_revealed) {
            // Déjà affiché (rafale de scroll) : pas de nouveau cycle
            // reveal/hide, juste on relance le délai d'auto-hide.
            autoHide.restart()
            return
        }

        if (!_mapped) {
            _positioning = true
            clientsProc.running = true
        } else if (!_positioning) {
            reveal()
        }
    }
}
