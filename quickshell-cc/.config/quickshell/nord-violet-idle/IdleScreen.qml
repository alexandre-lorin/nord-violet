import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

// Écran de veille "pluie de caractères" — déclenchement manuel pour
// l'instant (bind clavier ou `qs -c nord-violet-idle ipc call idle
// toggle`). PAS branché sur un vrai idle système : ça demanderait
// hypridle (pas confirmé installé) qui appellerait cette même commande
// IPC après un timeout d'inactivité, exactement comme il le ferait
// pour déclencher hyprlock. À faire quand tu veux passer à l'auto.
//
// PanelWindow (layer-shell) plutôt que Window : voir shell.qml pour le
// pourquoi (bug multi-écran remonté en usage réel). `screen:` assigné
// depuis Variants dans shell.qml, une instance par sortie.
PanelWindow {
    id: win
    // FIX #3 (retour utilisateur, log qs) : "IdleScreen does not have a
    // property called modelData" — Variants (contrairement à l'ancien
    // Repeater) n'injecte pas modelData implicitement dans le scope du
    // délégué, elle le set comme required property sur l'instance. Sans
    // cette déclaration, shell.qml ("screen: modelData") n'avait rien à
    // quoi se raccrocher.
    required property var modelData
    screen: modelData
    signal closeRequested()

    WlrLayershell.layer: WlrLayer.Overlay
    // Focus clavier exclusif : nécessaire pour que Échap/n'importe
    // quelle touche ferme la page de façon fiable, y compris quand la
    // fenêtre est apparue via l'appel IPC (pas un clic utilisateur qui
    // donnerait le focus "naturellement").
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "nord-violet-idle"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    // -1 : passe au-dessus de tout, y compris les exclusiveZone des
    // autres surfaces layer-shell (waybar) — cohérent avec le rôle
    // d'overlay plein écran.
    exclusiveZone: -1
    color: bgColor

    property color rainColor: "#9b7cff"
    readonly property color bgColor: "#020204"
    readonly property int fontSize: 18
    property int colCount: Math.max(1, Math.floor(width / fontSize))
    property var drops: []

    function resetDrops() {
        var arr = []
        for (var i = 0; i < colCount; i++)
            arr.push(Math.floor(Math.random() * -40))
        drops = arr
    }

    onColCountChanged: resetDrops()
    onVisibleChanged: {
        if (visible) {
            resetDrops()
            focusItem.forceActiveFocus()
            rainCanvas.requestPaint()
        }
        // FIX #4 (retour utilisateur : le curseur reste visible tant que
        // la souris ne bouge pas, il ne disparaît qu'au premier
        // mouvement). Deux tentatives précédentes ratées, toutes les deux
        // côté CLIENT :
        //   - cursorShape Qt.BlankCursor togglé par Timer : property Qt
        //     locale, aucun événement Wayland envoyé, ne fait rien tant
        //     que la souris est immobile.
        //   - nudge du curseur via hyprctl movecursor pour forcer un
        //     événement motion : movecursor est un warp visuel côté
        //     compositeur, rien ne garantit qu'il livre un vrai event
        //     d'input au client — confirmé inefficace en usage réel.
        // Les deux dépendaient d'un cycle client (Qt reçoit un event ->
        // Qt redemande au compositeur d'afficher tel curseur). Fix réel :
        // sortir complètement de ce cycle, agir au niveau du
        // compositeur. Hyprland a une variable cursor:invisible (section
        // cursor, bool, off par défaut) qui dit au rendu de ne
        // simplement pas dessiner de curseur du tout, peu importe ce que
        // demandent les clients. Aucune dépendance à un event pointeur,
        // un serial, ou un client précis — s'applique immédiatement.
        cursorVisibilityProc.command = ["hyprctl", "keyword",
            "cursor:invisible", visible ? "true" : "false"]
        cursorVisibilityProc.running = true
    }
    Process { id: cursorVisibilityProc }

    Item {
        id: focusItem
        anchors.fill: parent
        focus: true

        // N'importe quelle touche ou clic referme. closeRequested()
        // plutôt qu'un visible = false local : une instance par écran,
        // fermer celle-ci seule laisserait l'autre affichée.
        Keys.onPressed: win.closeRequested()

        MouseArea {
            id: cursorArea
            anchors.fill: parent
            // Masque le curseur tant que l'écran de veille est affiché
            // (retour utilisateur).
            cursorShape: Qt.BlankCursor
            onClicked: win.closeRequested()
        }

        Canvas {
            id: rainCanvas
            anchors.fill: parent

            readonly property string charset: "アイウエオカキクケコサシスセソタチツテト0123456789:・.=*+-<>¦｜╌"

            Timer {
                interval: 55
                running: win.visible
                repeat: true
                onTriggered: rainCanvas.requestPaint()
            }

            onPaint: {
                var ctx = getContext("2d")
                ctx.fillStyle = "rgba(2, 2, 4, 0.15)"
                ctx.fillRect(0, 0, width, height)

                ctx.font = win.fontSize + "px monospace"
                ctx.textBaseline = "top"
                ctx.fillStyle = win.rainColor

                for (var i = 0; i < win.drops.length; i++) {
                    var ch = charset.charAt(Math.floor(Math.random() * charset.length))
                    var x = i * win.fontSize
                    var y = win.drops[i] * win.fontSize

                    ctx.fillText(ch, x, y)

                    if (y > height && Math.random() > 0.975)
                        win.drops[i] = 0
                    else
                        win.drops[i] = win.drops[i] + 1
                }
            }
        }
    }
}
