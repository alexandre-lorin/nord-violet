import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "theme"
import "components"

// Panneau Son : même typographie et densité que le calendrier.
// Placement confirmé avant révélation, conservé depuis le correctif v47.
Window {
    id: flyout
    title: "Nord Violet Audio Flyout"
    visible: false
    color: "transparent"
    width: 332
    // Hauteur calculée avant affichage pour conserver le placement sans saut.
    readonly property int sinkRowHeight: 54
    height: Math.min(224 + Math.max(1, root.audioSinks.length) * (sinkRowHeight + 6), 500)

    Item {
        id: focusItem
        anchors.fill: parent
        Keys.onEscapePressed: flyout.hideFlyout()
        focus: true
        Rectangle {
            id: card
            anchors.fill: parent
            radius: Theme.radiusLarge
            color: Theme.surface
            border.width: 1
            border.color: Theme.border
            clip: true
            opacity: flyout._revealed ? 1 : 0
            Behavior on opacity {
                enabled: flyout._revealed
                NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
            }
            Text {
                x: 20; y: 22; text: "Son"
                color: Theme.textPrimary
                font.family: "Inter"; font.pixelSize: 15; font.weight: Font.DemiBold
            }
            Rectangle {
                x: 278; y: 16; width: 34; height: 30; radius: Theme.radiusSmall
                color: muteMouse.containsMouse ? Theme.surfaceHover : "transparent"
                activeFocusOnTab: true
                border.width: activeFocus ? 1 : 0
                border.color: Theme.accent
                Keys.onReturnPressed: root.toggleMute()
                Keys.onSpacePressed: root.toggleMute()
                Accessible.role: Accessible.Button
                Accessible.name: root.audioMuted ? "Rétablir le son" : "Couper le son"
                Accessible.onPressAction: root.toggleMute()
                AudioIcon {
                    anchors.centerIn: parent; width: 18; height: 18
                    pct: root.audioMuted ? 0 : Math.max(1, root.audioPct)
                    color: root.audioMuted ? Theme.accent : Theme.textSecondary
                }
                MouseArea {
                    id: muteMouse
                    anchors.fill: parent; hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.toggleMute()
                    onDoubleClicked: mouse => { mouse.accepted = false }
                }
            }
            Row {
                x: 20; y: 60; spacing: 5
                Text {
                    text: root.audioPct; color: Theme.textPrimary
                    font.family: "Inter"; font.pixelSize: 34; font.weight: Font.DemiBold
                }
                Text {
                    anchors.bottom: parent.bottom; anchors.bottomMargin: 6
                    text: "%"; color: Theme.textMuted; font.family: "Inter"; font.pixelSize: 14
                }
            }
            Text {
                anchors.right: parent.right; anchors.rightMargin: 20; y: 78
                text: root.audioMuted ? "Son coupé" : "Volume de sortie"
                color: root.audioMuted ? Theme.accent : Theme.textMuted
                font.family: "Inter"; font.pixelSize: 11
            }
            Slider {
                id: volumeSlider
                x: 20; y: 111; width: 292; height: 24
                from: 0; to: 100; stepSize: 1; value: root.audioPct
                enabled: root.audioSinkName.length > 0
                Accessible.name: "Volume de sortie"
                onMoved: root.setVolume(value)
                background: Rectangle {
                    x: volumeSlider.leftPadding
                    y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                    width: volumeSlider.availableWidth; height: 4; radius: 2
                    color: Theme.border
                    Rectangle {
                        width: volumeSlider.visualPosition * parent.width
                        height: parent.height; radius: 2
                        color: root.audioMuted ? Theme.textMuted : Theme.accent
                    }
                }
                handle: Rectangle {
                    x: volumeSlider.leftPadding + volumeSlider.visualPosition * (volumeSlider.availableWidth - width)
                    y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                    width: 12; height: 12; radius: 6; color: Theme.textPrimary
                    border.color: volumeSlider.activeFocus ? Theme.accent : Theme.textPrimary
                    border.width: 2
                }
                WheelHandler {
                    onWheel: event => { if (event.angleDelta.y !== 0) root.setVolume(root.audioPct + (event.angleDelta.y > 0 ? 1 : -1)) }
                }
            }
            Rectangle { x: 20; y: 153; width: 292; height: 1; color: Theme.border }
            Text {
                x: 20; y: 170; text: "SORTIE AUDIO"; color: Theme.textMuted
                font.family: "Inter"; font.pixelSize: 10; font.letterSpacing: 1
            }
            Flickable {
                id: flick
                x: 20; y: 198; width: 292; height: parent.height - y - 20
                clip: true; contentWidth: width
                contentHeight: Math.max(54, outputs.implicitHeight)
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                Text {
                    visible: root.audioSinks.length === 0
                    anchors.centerIn: parent
                    text: root.readError ? "Audio indisponible" : root.loaded ? "Aucune sortie disponible" : "Chargement…"
                    color: Theme.textMuted; font.family: "Inter"; font.pixelSize: 12
                }
                Column {
                    id: outputs
                    width: flick.width; spacing: 6
                    Repeater {
                        model: root.audioSinks
                        delegate: Rectangle {
                            id: output
                            required property var modelData
                            readonly property bool current: modelData.name === root.audioSinkName
                            width: outputs.width; height: flyout.sinkRowHeight; radius: Theme.radiusSmall
                            color: current ? Theme.accentMuted : sinkMouse.containsMouse || activeFocus ? Theme.surfaceHover : "transparent"
                            border.width: current || activeFocus ? 1 : 0; border.color: Theme.accent
                            activeFocusOnTab: true
                            Accessible.role: Accessible.RadioButton
                            Accessible.name: modelData.desc + ", " + modelData.detail
                            Accessible.checked: current
                            Accessible.onPressAction: root.selectSink(modelData.name)
                            Keys.onReturnPressed: root.selectSink(modelData.name)
                            Keys.onSpacePressed: root.selectSink(modelData.name)
                            Column {
                                x: 12; anchors.verticalCenter: parent.verticalCenter; spacing: 4
                                width: parent.width - 44
                                Text {
                                    width: parent.width; text: output.modelData.desc
                                    color: output.current ? Theme.textPrimary : Theme.textSecondary
                                    font.family: "Inter"; font.pixelSize: 12; font.weight: Font.Medium
                                    elide: Text.ElideRight
                                }
                                Text {
                                    width: parent.width; text: output.modelData.detail
                                    color: Theme.textMuted; font.family: "Inter"; font.pixelSize: 10
                                    elide: Text.ElideRight
                                }
                            }
                            Text {
                                anchors.right: parent.right; anchors.rightMargin: 12
                                anchors.verticalCenter: parent.verticalCenter
                                text: "✓"; visible: output.current
                                font.family: "Inter"; font.pixelSize: 13; color: Theme.accent
                            }
                            MouseArea {
                                id: sinkMouse
                                anchors.fill: parent; hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.selectSink(output.modelData.name)
                            }
                        }
                    }
                }
            }
        }
        HoverHandler {
            id: rootHover
            target: card
            onHoveredChanged: {
                if (hovered) { flyout._wasHovered = true; hideGrace.stop() }
                else if (flyout._wasHovered && !flyout.active) hideGrace.restart()
            }
        }
    }

    QtObject {
        id: root
        property int audioPct: 0
        property bool audioMuted: false
        property string audioSinkName: ""
        property var audioSinks: []
        property bool loaded: false
        property bool readError: false
        property int requestedVolume: -1
        property int sentVolume: -1
        function setVolume(pct) {
            if (!audioSinkName) return
            audioPct = Math.max(0, Math.min(100, Math.round(pct)))
            requestedVolume = audioPct
            volumeDebounce.restart()
        }
        function sendVolume() {
            if (audioSet.running || requestedVolume < 0) return
            sentVolume = requestedVolume
            audioSet.command = ["python3", "/home/toubi/.config/quickshell/nord-violet-cc/scripts/audio-devices.py", "set-volume", sentVolume + "%"]
            audioSet.running = true
        }
        function toggleMute() {
            if (!audioSinkName || muteSet.running) return
            muteSet.command = ["python3", "/home/toubi/.config/quickshell/nord-violet-cc/scripts/audio-devices.py", "toggle-mute"]
            muteSet.running = true
        }
        function selectSink(name) {
            if (sinkSet.running || audioSet.running || volumeDebounce.running) return
            sinkSet.command = ["python3", "/home/toubi/.config/quickshell/nord-violet-cc/scripts/audio-devices.py", "select", name]
            sinkSet.running = true
        }
    }
    Timer { id: volumeDebounce; interval: 35; onTriggered: root.sendVolume() }
    Timer {
        interval: 1000; repeat: true; running: flyout._revealed
        onTriggered: if (!audioSet.running && !volumeSlider.pressed && !volumeDebounce.running && !sinkSet.running) audioSinksRead.running = true
    }
    // Synchronisation immédiate avec les changements externes (molette
    // Waybar, touches média, pavucontrol). Le timer reste un filet de
    // sécurité ; ce flux évite jusqu'à une seconde de retard visible.
    Process {
        command: ["pactl", "subscribe"]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: line => {
                if (flyout._revealed && (line.indexOf(" on sink #") >= 0 || line.indexOf(" on server #") >= 0)
                        && !audioSet.running && !volumeSlider.pressed
                        && !volumeDebounce.running && !sinkSet.running) {
                    audioRefreshDelay.start()
                }
            }
        }
    }
    Timer {
        id: audioRefreshDelay
        interval: 35
        onTriggered: {
            if (!flyout._revealed) return
            if (audioSinksRead.running || audioSet.running || volumeSlider.pressed || volumeDebounce.running || sinkSet.running) { restart(); return }
            audioSinksRead.running = true
        }
    }
    Process {
        id: audioSet
        onExited: {
            if (root.requestedVolume !== root.sentVolume) root.sendVolume()
            else audioSinksRead.running = true
        }
    }
    Process { id: muteSet; onExited: audioSinksRead.running = true }
    Process { id: sinkSet; onExited: audioSinksRead.running = true }
    Process {
        id: audioSinksRead
        command: ["python3", "/home/toubi/.config/quickshell/nord-violet-cc/scripts/audio-devices.py", "snapshot"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const state = JSON.parse(text)
                    const rows = state.sinks.map(s => ({name: s.name, desc: s.desc, detail: s.detail}))
                    if (JSON.stringify(root.audioSinks) !== JSON.stringify(rows)) root.audioSinks = rows
                    root.audioSinkName = state.default
                    const current = state.sinks.find(s => s.name === state.default)
                    if (current && !volumeSlider.pressed && !audioSet.running && !volumeDebounce.running) root.audioPct = current.volume
                    root.audioMuted = current ? current.muted : false
                    root.loaded = true
                    root.readError = false
                } catch (error) { root.readError = true }
                if (flyout._wantOpen && flyout._positioning) positionRetry.restart()
            }
        }
        onExited: exitCode => {
            if (exitCode !== 0) {
                root.readError = true
                if (flyout._wantOpen && flyout._positioning) positionRetry.restart()
            }
        }
    }

    // -- Positionnement + animation -----------------------------------------
    // v47 — confirmer la taille et la position réelles, puis révéler.
    // no_anim côté Hyprland évite le déplacement animé sous le fondu QML.
    Process {
        id: moveProc
        stderr: StdioCollector {
            onStreamFinished: if (text.trim()) console.warn("[flyout] position:", text.trim())
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0 || !flyout._wantOpen) {
                flyout._positioning = false
                return
            }
            flyout._mapped = true
            if (flyout._geometryDirty) {
                monitorsProc.running = true
                return
            }
            flyout._positioning = false
            if (!flyout._revealed) flyout.reveal()
        }
    }

    // Le popup suit le point de clic Waybar : centré sous le bouton puis
    // clampé dans l'écran qui contient réellement le curseur.
    Process {
        id: monitorsProc
        command: ["hyprctl", "monitors", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                var mons
                try { mons = JSON.parse(text) } catch (e) { console.log("[audio-flyout] JSON monitors invalide:", e); flyout._positioning = false; return }
                var mon = null
                for (var i = 0; i < mons.length; i++) {
                    if (mons[i].focused) { mon = mons[i]; break }
                }
                if (!mon && mons.length > 0) mon = mons[0] // filet de sécurité
                if (!mon) { console.log("[audio-flyout] aucun moniteur focus trouvé"); flyout._positioning = false; return }

                flyout._geometryDirty = false
                moveProc.command = ["python3", "/home/toubi/.config/quickshell/nord-violet-cc/scripts/flyout-workspace.py", "position-click", "nvaudio", String(flyout.width), String(flyout.height), String(flyout._clickX), String(flyout._clickY)]
                moveProc.running = true
            }
        }
    }

    // Ne sert plus qu'à confirmer que la fenêtre existe déjà côté
    // compositeur (1re ouverture seulement, avant qu'on puisse lui
    // envoyer un movewindowpixel) — le moniteur cible vient maintenant
    // du clic (monitorsProc ci-dessus), plus de ce lookup.
    Process {
        id: clientsProc
        command: ["hyprctl", "clients", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                var clients
                try { clients = JSON.parse(text) } catch (e) { console.log("[audio-flyout] JSON clients invalide:", e); return }
                var found = null
                for (var i = 0; i < clients.length; i++) if (clients[i].title === "Nord Violet Audio Flyout") { found = clients[i]; break }
                if (!found) { console.log("[audio-flyout] fenêtre pas encore mappée"); positionRetry.start(); return }
                monitorsProc.running = true
            }
        }
    }

    Timer { id: positionRetry; interval: 40; onTriggered: clientsProc.running = true }

    // v27 — special workspace (voir plus haut). `_revealed` = workspace
    // spéciale actuellement togglée visible ou non (indépendant de
    // `visible` QML, qui reste true en permanence après le 1er show()).
    // `_positioning` = calcul de position en cours (1re fois seulement),
    // pour ignorer un show() qui arrive pendant ce court instant plutôt
    // que révéler avant que la position soit posée.
    property bool _revealed: false
    property bool _positioning: false
    // v28 : ne PLUS se fier à `visible` pour savoir si la fenêtre a déjà
    // été positionnée — `visible` semble se réinitialiser (côté
    // compositeur ?) quand la special workspace se cache, ce qui
    // relançait toute la chaîne clients->monitors->move À CHAQUE clic
    // au lieu d'une seule fois (confirmé en live : logs identiques
    // répétés). Flag séparé, sous notre contrôle exclusif.
    property bool _mapped: false

    // Recaler la taille réelle lorsque les données asynchrones changent
    // la hauteur. Pendant l'ouverture, attendre le dernier placement.
    property bool _wantOpen: false
    property bool _geometryDirty: false
    onHeightChanged: {
        if (visible && _wantOpen && (_mapped || _positioning)) {
            _geometryDirty = true
            geometryRefresh.restart()
        }
    }
    Timer {
        id: geometryRefresh
        interval: 40
        onTriggered: {
            if (flyout._wantOpen && flyout._geometryDirty && !flyout._positioning && flyout.visible) {
                flyout._positioning = true
                monitorsProc.running = true
            }
        }
    }


    Process {
        id: toggleSpecialProc
        command: ["python3", "/home/toubi/.config/quickshell/nord-violet-cc/scripts/flyout-workspace.py", "show", "nvaudio"]
        stderr: StdioCollector { onStreamFinished: if (text.trim().length > 0) console.log("[audio-flyout] togglespecial stderr:", text.trim()) }
    }

    function reveal() {
        console.log("[audio-flyout] reveal() appelé")

        toggleSpecialProc.command = ["python3", "/home/toubi/.config/quickshell/nord-violet-cc/scripts/flyout-workspace.py", "show", "nvaudio"]
        toggleSpecialProc.running = true
        _revealed = true
    }

    function hideFlyout() {
        console.log("[audio-flyout] hideFlyout() appelé — _revealed:", _revealed)
        _wantOpen = false
        geometryRefresh.stop()
        if (!_revealed) return
        toggleSpecialProc.command = ["python3", "/home/toubi/.config/quickshell/nord-violet-cc/scripts/flyout-workspace.py", "hide", "nvaudio"]
        toggleSpecialProc.running = true
        _revealed = false
    }

    // v31 — fermeture avec un peu de tolérance : perdre le focus une
    // fraction de seconde (micro-mouvement de souris, clic qui frôle le
    // bord) ne ferme plus instantanément. Un vrai "je m'éloigne" laisse
    // le délai courir jusqu'au bout et ferme comme avant. Annulé si le
    // focus revient avant.
    Timer {
        id: hideGrace
        interval: 220
        onTriggered: flyout.hideFlyout()
    }

    // v35 — retour de test v34 : "quand je m'éloigne, ça ne ferme pas".
    // Juste : le v31 ne fermait QUE sur perte de focus (clic ailleurs),
    // pas quand la souris s'éloigne sans cliquer — aucun handler
    // n'existait pour ce cas, donc rien ne se déclenchait, comme
    // signalé. Fix : un HoverHandler sur `card` (toute la surface du
    // flyout) — le timer de fermeture ne repart que si NI le focus NI
    // le survol ne sont actifs ; il s'arrête dès que l'un des deux
    // revient. Le HoverHandler lui-même est déclaré plus haut, DANS
    // `focusItem` (un Item) — pas ici : un PointerHandler ne peut pas
    // être enfant direct d'un `Window`, qui n'est pas un Item. Trouvé
    // en relisant après coup, jamais testé avant correction.
    onActiveChanged: {
        console.log("[audio-flyout] onActiveChanged — active:", active, "_mapped:", _mapped, "_revealed:", _revealed)
        if (active) hideGrace.stop()
        else if (!rootHover.hovered) hideGrace.restart()
    }

    property real _clickX: 0
    property real _clickY: 0
    property bool _wasHovered: false

    function show(x, y) {
        _clickX = x
        _clickY = y
        _wasHovered = false
        hideGrace.stop()
        if (_positioning) return

        _wantOpen = true
        _positioning = true
        _revealed = false
        visible = true
        // Le callback de cette lecture démarre le placement après mise en page.
        audioSinksRead.running = true
    }
}
