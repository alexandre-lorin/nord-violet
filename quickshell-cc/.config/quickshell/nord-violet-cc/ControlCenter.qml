import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "theme"
import "components"
import "pages" as Pages

// v9 — POPUP SEUL. Ce fichier ne contient plus que l'écran d'accueil
// (ex-"overviewShellComponent"). Les 7 pages Réglages/Avancé vivent
// maintenant dans SettingsWindow.qml, une fenêtre séparée, ouverte via
// le bouton "Réglages ›" ci-dessous ou par IPC (`qs ... ipc call
// settings open`). Voir HANDOFF.md v9 pour le pourquoi.
//
// 🔴 VRAI BUG windowrule trouvé en v9 (celui qui restait après le
// reorder action/match de v8) : `width: 620` / `height: 580` étaient
// des BINDINGS QML permanents sur la Window, pas juste une taille de
// départ. Un binding constant sur `width`/`height` regagne la main à
// chaque fois que quelque chose d'autre essaie de la changer — y
// compris le `configure` envoyé par Hyprland pour appliquer
// `size 66% 66%`. Résultat : la fenêtre "acceptait" la règle une
// fraction de seconde puis se re-forçait elle-même à 620×580, d'où
// - le popup qui ne prenait jamais vraiment 66%×66%, et
// - le scroll interne nécessaire pour voir tout le panneau (contenu
//   qui a besoin de plus de hauteur que les 580px imposés).
// Fix : `width`/`height` ne sont plus des bindings — juste une valeur
// de départ assignée une fois dans Component.onCompleted. Après ça,
// Hyprland peut redimensionner librement, aucun ping-pong avec le QML.
Window {
    id: panel
    title: "Nord Violet Control Center"
    visible: false
    color: "transparent"

    // Taille de DÉPART seulement (pas un binding — voir note ci-dessus).
    // windowrules.conf prend ensuite la main via `size 66% 66%`.
    // v15 : encore réduite (560/600 → 480/520) — le header ("Control
    // Center" / "Nord Violet" / le "N") a été retiré, jugé inutile
    // (demande explicite), donc encore moins de hauteur nécessaire.
    minimumWidth: 620
    minimumHeight: 290
    maximumHeight: 320
    Component.onCompleted: {
        width = 620
        height = 320
    }

    // v16 : accès direct depuis waybar (clic molette son / clic réseau)
    // sans passer par la carte du panneau — `shell.qml` appelle ces
    // fonctions via l'IpcHandler `cc` (`ipc call cc audio` / `cc wifi`),
    // qui appelle aussi `panel.openPanel()` avant (v36 : plus
    // `panel.visible = true` direct, voir migration special-workspace).
    function openAudioPicker() { overviewPageItem.openAudioPicker() }
    function openWifiPicker() { overviewPageItem.openWifiPicker() }

    // v17.2 — repositionnement bas-droite, v3 : le vrai bug trouvé.
    // `hyprctl dispatch movewindowpixel exact X Y` travaille en
    // coordonnées GLOBALES (tout l'espace multi-écran mis bout à
    // bout), pas relatives à l'écran affiché. `Screen.width/height`
    // (v17.1) donnait la résolution de l'écran QML — mais confirmé en
    // live : ça donnait eDP-1 (1920×1080, focus au sens Qt) alors que
    // le panneau s'ouvre en fait sur HDMI-A-1 (2560×1440, à l'origine
    // globale 0x0, eDP-1 étant décalé à 2560x0). Le calcul "bas-droite
    // d'un écran 1920×1080" appliqué tel quel en coordonnées globales
    // retombait donc au milieu de HDMI-A-1 — d'où le "toujours centré"
    // depuis le début, pas un souci de move cassé.
    //
    // Fix : on ne devine plus l'écran, on le demande à Hyprland —
    // `hyprctl clients -j` pour savoir sur quel moniteur (id) est
    // RÉELLEMENT la fenêtre, puis `hyprctl monitors -j` pour sa
    // géométrie exacte en coordonnées globales (x/y/width/height +
    // `reserved`, qui inclut déjà l'espace pris par waybar — plus
    // besoin de deviner sa hauteur à la main).
    //
    // ASSUMPTION pas vérifiée : `reserved` et `width`/`height` de
    // `hyprctl monitors -j` sont supposés en pixels logiques déjà
    // divisés par `scale` — vrai ici (scale: 1 sur tes 2 écrans selon
    // ton `hyprctl monitors`), mais si tu scales un jour un écran, ce
    // calcul sera à revoir (diviser par le bon facteur).
    readonly property int reposMarginRight: 12
    readonly property int reposMarginBottom: 12 // petite marge, `reserved` gère déjà waybar

    Process {
        id: reposMoveProc
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0) console.log("[reposition] move stdout:", text.trim())
                // v39 — MÊME BUG que AudioFlyout/WifiFlyout (trouvé en
                // même temps, jamais détecté avant : "le son pop en bas
                // au milieu puis transporté à droite" en test live) :
                // `_afterReposition()` (qui révèle via la special
                // workspace) était appelé JUSTE APRÈS avoir lancé ce
                // process, pas après sa confirmation — les deux dispatches
                // hyprctl (move + toggle special workspace) partaient
                // quasi en parallèle. Déplacé ici, dans onStreamFinished :
                // ne se déclenche qu'une fois le déplacement confirmé.
                panel._afterReposition()
            }
        }
        stderr: StdioCollector {
            onStreamFinished: if (text.trim().length > 0) console.log("[reposition] move stderr:", text.trim())
        }
    }

    Process {
        id: reposMonitorsProc
        command: ["hyprctl", "monitors", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                var mons
                try { mons = JSON.parse(text) } catch (e) {
                    console.log("[reposition] JSON invalide sur hyprctl monitors -j:", e)
                    return
                }
                // v38 — retour de test v37 : "si je change vite de
                // moniteur de focus c'est pas direct". Cause : le CC se
                // positionnait sur le moniteur où la fenêtre se trouvait
                // DÉJÀ (`found.monitor` de hyprctl clients -j, son
                // ancienne position), pas sur celui actuellement
                // FOCUS — contrairement aux flyouts qui suivent le vrai
                // point de clic à chaque fois. Ne dépend plus de
                // `_reposTargetMonitorId`/`found.monitor` pour choisir la
                // cible : cherche directement le moniteur `focused: true`
                // dans ce même appel `hyprctl monitors -j`.
                var mon = null
                for (var i = 0; i < mons.length; i++) {
                    if (mons[i].focused) { mon = mons[i]; break }
                }
                if (!mon && mons.length > 0) mon = mons[0] // filet de sécurité
                if (!mon) {
                    console.log("[reposition] aucun moniteur focus trouvé dans hyprctl monitors -j")
                    return
                }
                // reserved = [gauche, haut, droite, bas] en pixels logiques
                var reservedBottom = (mon.reserved && mon.reserved.length === 4) ? mon.reserved[3] : 0
                var x = Math.round(mon.x + mon.width - panel.width - panel.reposMarginRight)
                var y = Math.round(mon.y + mon.height - reservedBottom - panel.height - panel.reposMarginBottom)
                var arg = "exact " + x + " " + y + ",title:^(Nord Violet Control Center)$"
                console.log("[reposition] moniteur focus", mon.name, "x:", mon.x, "y:", mon.y, "w:", mon.width, "h:", mon.height, "reservedBottom:", reservedBottom, "-> dispatch", arg)
                reposMoveProc.command = ["hyprctl", "dispatch", "movewindowpixel", arg]
                reposMoveProc.running = true
                // v39 — _afterReposition() ne se déclenche plus ici
                // (voir note sur reposMoveProc plus haut) : déplacé dans
                // son onStreamFinished, une fois le move confirmé.
            }
        }
    }

    Timer { id: reposRetry; interval: 40; onTriggered: panel.doReposition() }

    // La contrainte de taille Qt des overlays audio/Wi-Fi peut faire
    // remonter la surface à 480 px malgré la règle Hyprland. On impose la
    // taille compacte après confirmation du mapping, avant le placement.
    Process {
        id: compactSizeProc
        command: ["hyprctl", "dispatch", "resizewindowpixel", "exact 620 320,title:^(Nord Violet Control Center)$"]
        stdout: StdioCollector { onStreamFinished: reposMonitorsProc.running = true }
    }

    // v38 — reposClientsProc ne sert plus qu'à confirmer que la fenêtre
    // existe déjà côté compositeur (avant de pouvoir la déplacer) — plus
    // à déterminer SUR QUEL moniteur (voir reposMonitorsProc ci-dessus,
    // qui prend maintenant le moniteur focus directement).
    Process {
        id: reposClientsProc
        command: ["hyprctl", "clients", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                var clients
                try { clients = JSON.parse(text) } catch (e) {
                    console.log("[reposition] JSON invalide sur hyprctl clients -j:", e)
                    return
                }
                var found = null
                for (var i = 0; i < clients.length; i++) {
                    if (clients[i].title === "Nord Violet Control Center") { found = clients[i]; break }
                }
                if (!found) {
                    // v31 : avant, on abandonnait ici sans retenter — sans
                    // le filet de sécurité du timer fixe retiré ci-dessus,
                    // ça pouvait laisser le panneau invisible pour de bon
                    // si ce premier essai tombait avant que la fenêtre
                    // soit mappée côté compositeur. Retry, même mécanique
                    // que positionRetry dans AudioFlyout/WifiFlyout.
                    console.log("[reposition] fenêtre \"Nord Violet Control Center\" introuvable dans hyprctl clients -j (pas encore mappée ?) — retry")
                    reposRetry.start()
                    return
                }
                console.log("[reposition] fenêtre confirmée mappée (moniteur actuel", found.monitor, ", ignoré — on cible le moniteur focus)")
                compactSizeProc.running = true
            }
        }
    }

    // v38 — `_reposTargetMonitorId` retiré : le moniteur cible vient
    // maintenant directement de `focused: true` dans reposMonitorsProc,
    // plus besoin de le faire transiter par une propriété entre les 2
    // process (voir reposClientsProc/reposMonitorsProc plus haut).
    // v24 : le panel s'affichait au centre (position par défaut Hyprland
    // pour une nouvelle fenêtre flottante) le temps que le cycle
    // clients->monitors->move (2 round-trips hyprctl) se termine — même
    // avec noanim ça flashait un instant à la mauvaise place avant de
    // sauter. Même pattern que AudioFlyout/WifiFlyout (déjà en place
    // depuis v18) : contenu masqué (opacity 0) tant que la position
    // finale n'est pas confirmée, révélé seulement une fois le dispatch
    // move émis. `_revealed` remis à false à chaque fermeture ET à
    // chaque changement de taille (le `size 66% 66%` de la windowrule
    // arrive APRÈS la taille de départ 480x520 -> 2e cycle de
    // repositionnement -> on re-masque pour ne pas voir ce 2e saut non plus.
    property bool _revealed: false

    // v36 — MIGRATION vers le pattern special-workspace des flyouts
    // (AudioFlyout.qml/WifiFlyout.qml), au lieu du toggle direct de
    // `visible`. Raison : le fix v31 (masquer via opacity le temps du
    // repositionnement) supposait que si le contenu QML est invisible,
    // rien ne peut se voir à l'écran pendant le repositionnement — vrai
    // pour le contenu QML, mais le popup continuait à apparaître centré
    // une fraction de seconde avant de sauter (confirmé en test live
    // v35, même après avoir tenté no_shadow/no_blur en hypothèse — pas
    // la bonne piste). Cause la plus probable : basculer `visible`
    // true/false DÉMAPPE/REMAPPE la surface Wayland à chaque
    // ouverture, ce qui redéclenche le placement par défaut de
    // Hyprland (centré) à chaque fois, quoi qu'on fasse côté QML. Les
    // flyouts n'ont jamais eu ce problème parce qu'ils ne togglent
    // jamais `visible` après le tout premier `show()` — seule la
    // special workspace (un simple show/hide d'overlay, pas un
    // remap) est togglée ensuite. Même principe appliqué ici.
    //
    // `_shown` = la special workspace est actuellement affichée
    // (concept togglé, un seul hyprctl dispatch fait office de show ET
    // hide). `_revealed` = le contenu QML (opacity) est démasqué —
    // reste utile séparément de `_shown` parce que le repositionnement
    // peut arriver 2 fois au même open (position de départ 480×520,
    // puis le 66%×66% de la windowrule qui arrive après) : on
    // re-masque le contenu à chaque repositionnement pour ne pas voir
    // le saut, mais on ne veut PAS re-toggler la special workspace à
    // la 2e passe (elle est déjà affichée — la re-toggler la
    // fermerait, puisque `togglespecialworkspace` inverse l'état à
    // chaque appel, pas un show explicite).
    property bool _shown: false

    Process {
        id: toggleSpecialProc
        command: ["hyprctl", "dispatch", "togglespecialworkspace", "nvcc"]
        stderr: StdioCollector { onStreamFinished: if (text.trim().length > 0) console.log("[cc] togglespecial stderr:", text.trim()) }
    }

    // Point de sortie commun de doReposition() — appelé après CHAQUE
    // repositionnement réussi, potentiellement plusieurs fois par open.
    function _afterReposition() {
        _mapped = true
        _revealed = true
        _positioning = false
        if (!_shown) {
            toggleSpecialProc.running = true
            _shown = true
        }
    }

    property bool _mapped: false
    // v38 — même garde-fou anti-course que les flyouts (voir
    // AudioFlyout.qml/WifiFlyout.qml) : évite de relancer une 2e chaîne
    // clients->monitors->move si une est déjà en vol (ouverture rapide
    // via le bind $mainMod+S répété, par ex.).
    property bool _positioning: false

    function openPanel() {
        if (_shown || _positioning) return
        visible = true
        doReposition()
    }

    function closePanel() {
        if (!_shown) return
        toggleSpecialProc.running = true
        _shown = false
        _revealed = false
    }

    function togglePanel() {
        if (_shown) closePanel()
        else openPanel()
    }

    // v31 — BUG TROUVÉ (le "pop au milieu puis téléportation" signalé en
    // test live) : `revealDelay` révélait le panneau après un délai FIXE
    // de 140ms, en pariant que le cycle hyprctl clients->monitors->move
    // (2 process forkés en série) aurait fini avant. Sur une machine
    // chargée — ou juste par malchance — ce pari est perdu : le panneau
    // devient visible AVANT que movewindowpixel soit dispatché, donc
    // Hyprland le place à sa position par défaut (centré) le temps que
    // le move arrive, d'où le flash centre -> saut coin bas-droite.
    // Fix : plus de pari sur un délai. `_revealed` ne passe à true que
    // dans `reposMonitorsProc.onStreamFinished`, juste APRÈS avoir
    // effectivement émis le dispatch move — exactement le même principe
    // que AudioFlyout/WifiFlyout (`reveal()` appelé au même endroit).
    Timer {
        id: repositionDebounce
        interval: 80
        onTriggered: panel.doReposition()
    }

    function scheduleReposition() {
        if (visible) {
            _revealed = false
            repositionDebounce.restart()
        }
    }

    function doReposition() {
        console.log("[reposition] tick — visible:", visible, "panel.width:", width, "panel.height:", height)
        if (!visible || width <= 0 || height <= 0) {
            console.log("[reposition] abort — pas visible ou taille pas encore connue")
            return
        }
        _positioning = true
        reposClientsProc.running = true
    }

    // v17.1 — exposé pour test manuel : `qs -c nord-violet-cc ipc call
    // cc reposition` pendant que le panneau est déjà ouvert.
    function forceReposition() { doReposition() }

    // v36 — plus de `onVisibleChanged` ici : `visible` ne passe plus
    // que UNE fois de false à true, pour toute la durée de la session
    // (voir openPanel()/closePanel() plus haut, qui togglent la
    // special workspace, pas `visible`). Le tout premier `doReposition()`
    // est maintenant déclenché explicitement par `openPanel()`. Les 2
    // triggers ci-dessous restent nécessaires : ils gèrent le 2e
    // repositionnement quand la windowrule `size 66% 66%` change
    // width/height après le placement de départ (480×520).
    onWidthChanged: scheduleReposition()
    onHeightChanged: scheduleReposition()

    Rectangle {
        id: rootRect
        anchors.fill: parent
        radius: Theme.radiusLarge
        color: Theme.background
        border.width: 1
        border.color: Theme.border
        clip: true
        opacity: panel._revealed ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

        // v15 : garde le focus clavier pour Échap (voir Keys plus bas)
        // et le reprend à chaque ouverture du popup audio (un clic sur
        // une entrée de la liste, par ex., peut faire dériver le focus).
        focus: true
        Keys.onEscapePressed: {
            if (overviewPageItem.audioPickerOpen) overviewPageItem.closeAudioPicker()
            else if (overviewPageItem.wifiPickerOpen) overviewPageItem.closeWifiPicker()
            else panel.closePanel()
        }
        Keys.onPressed: event => {
            if (event.key === Qt.Key_S && !overviewPageItem.audioPickerOpen && !overviewPageItem.wifiPickerOpen) {
                settingsOpenProc.running = true
                event.accepted = true
            }
        }

        Connections {
            target: overviewPageItem
            function onAudioPickerOpenChanged() {
                if (overviewPageItem.audioPickerOpen) rootRect.forceActiveFocus()
            }
            function onWifiPickerOpenChanged() {
                if (overviewPageItem.wifiPickerOpen) rootRect.forceActiveFocus()
            }
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                color: "#090a0e"
                border.width: 1
                border.color: Theme.border
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    Text { text: "NV / CONTROL"; color: Theme.accent; font.family: "JetBrains Mono"; font.pixelSize: 10; font.bold: true; font.letterSpacing: 1 }
                    Item { Layout.fillWidth: true }
                    Text { text: "profil: " + overviewPageItem.profileName.toLowerCase(); color: Theme.textMuted; font.family: "JetBrains Mono"; font.pixelSize: 9 }
                }
            }

            // En-tête décorative volontairement absente : le panneau va
            // directement aux commandes utiles.
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.maximumHeight: overviewPageItem.implicitHeight
                Layout.alignment: Qt.AlignTop
                Layout.topMargin: 10
                Layout.leftMargin: 14
                Layout.rightMargin: 14

                Flickable {
                    id: overviewFlick
                    anchors.fill: parent
                    clip: true
                    contentWidth: width
                    contentHeight: Math.max(height, overviewPageItem.implicitHeight)
                    boundsBehavior: Flickable.StopAtBounds

                    Pages.OverviewPage {
                        id: overviewPageItem
                        pollingActive: panel._revealed
                        width: overviewFlick.width
                    }
                }

                MouseArea {
                    anchors.fill: overviewFlick
                    acceptedButtons: Qt.NoButton
                    onWheel: event => {
                        var step = 60
                        var dy = event.angleDelta.y > 0 ? -step : step
                        overviewFlick.contentY = Math.max(0, Math.min(
                            overviewFlick.contentHeight - overviewFlick.height,
                            overviewFlick.contentY + dy
                        ))
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 28
                color: "#090a0e"
                border.width: 1
                border.color: Theme.border
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 8
                    Text { text: "[S]"; color: Theme.accent; font.family: "JetBrains Mono"; font.pixelSize: 9 }
                    Text { text: "réglages"; color: Theme.textMuted; font.family: "JetBrains Mono"; font.pixelSize: 9 }
                    Item { Layout.fillWidth: true }
                    Text { text: "audio sync: live"; color: Theme.textMuted; font.family: "JetBrains Mono"; font.pixelSize: 9 }
                }
                TapHandler { onTapped: settingsOpenProc.running = true }
            }

        }

        Process { id: settingsOpenProc; command: ["qs", "-c", "nord-violet-cc", "ipc", "call", "settings", "page", "overview"] }

        // -- Popup sortie audio (v14) — au-dessus de TOUT le panneau ---
        // Demande explicite : "tu tapes sur le carré entier et ça te
        // met un popup stylé comme les iPhones, par-dessus des autres
        // trucs". Déclaré ici (après la ColumnLayout, dans le même
        // Rectangle racine) pour peindre par-dessus header/hero/quick
        // controls/Réglages — pas juste par-dessus la carte Audio.
        // État/actions lus directement sur `overviewPageItem` (id de
        // la page Overview plus haut) : audioPickerOpen/audioSinks/
        // audioPct/audioSink/audioSinkName + les fonctions
        // openAudioPicker/closeAudioPicker/setVolume/selectSink.
        Rectangle {
            id: audioScrim
            anchors.fill: parent
            radius: parent.radius
            color: Qt.rgba(0, 0, 0, 0.55)
            visible: opacity > 0
            opacity: overviewPageItem.audioPickerOpen ? 1 : 0

            // v15 : animation d'ouverture plus travaillée (demande
            // explicite) — fondu + léger scale-in avec un easing
            // "overshoot" doux (OutBack, léger dépassement puis retour),
            // au lieu du fondu linéaire plat de v14.
            Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

            TapHandler { onTapped: overviewPageItem.closeAudioPicker() }

            Rectangle {
                id: audioPopup
                anchors.centerIn: parent
                width: parent.width - Theme.spacingLG * 2
                implicitHeight: popupCol.implicitHeight + Theme.spacingLG * 2
                radius: Theme.radiusLarge
                color: Theme.surface
                border.width: 1
                border.color: Theme.accent
                scale: 0.9 + 0.1 * audioScrim.opacity
                transformOrigin: Item.Center

                // Absorbe les taps à l'intérieur du popup — sans ça ils
                // retombent sur le TapHandler du scrim juste en dessous
                // et referment le popup au moindre clic dans le vide.
                MouseArea { anchors.fill: parent; onClicked: {} }

                ColumnLayout {
                    id: popupCol
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: Theme.spacingLG
                    spacing: Theme.spacingMD

                    // v16 : header restylé façon flyout "Quick Settings" —
                    // icône badge + titre sur une ligne, au lieu du simple
                    // label uppercase. Même badge que HeroStat.icon
                    // (accentMuted/accent), pas de nouvel élément visuel
                    // introduit dans le projet.
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacingSM

                        Rectangle {
                            implicitWidth: 26
                            implicitHeight: 26
                            radius: Theme.radiusSmall
                            color: Theme.accentMuted
                            border.width: 1
                            border.color: Theme.accent
                            AudioIcon {
                                anchors.centerIn: parent
                                pct: overviewPageItem.audioPct
                                color: Theme.accent
                                implicitWidth: 14
                                implicitHeight: 14
                            }
                        }
                        Text {
                            text: "Sortie audio"
                            color: Theme.textPrimary
                            font.pixelSize: Theme.fontBody
                            font.bold: true
                            Layout.fillWidth: true
                        }
                    }

                    Text {
                        text: overviewPageItem.audioPct + "%"
                        color: Theme.textPrimary
                        font.pixelSize: Theme.fontDisplay
                        font.bold: true
                        font.letterSpacing: -1
                    }

                    Item {
                        id: popupSliderTrack
                        Layout.fillWidth: true
                        implicitHeight: 20

                        readonly property real clamped: Math.max(0, Math.min(1, overviewPageItem.audioPct / 100))

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            height: 6
                            radius: 3
                            color: Theme.surfaceHover

                            Rectangle {
                                width: parent.width * popupSliderTrack.clamped
                                height: parent.height
                                radius: parent.radius
                                color: Theme.accent
                            }
                        }

                        Rectangle {
                            width: 16
                            height: 16
                            radius: 8
                            color: Theme.textPrimary
                            border.width: 2
                            border.color: Theme.accent
                            anchors.verticalCenter: parent.verticalCenter
                            x: popupSliderTrack.clamped * (popupSliderTrack.width - width)
                        }

                        MouseArea {
                            anchors.fill: parent
                            onPressed: (mouse) => overviewPageItem.setVolume(100 * mouse.x / popupSliderTrack.width)
                            onPositionChanged: (mouse) => { if (pressed) overviewPageItem.setVolume(100 * mouse.x / popupSliderTrack.width) }
                        }

                        WheelHandler {
                            onWheel: (event) => overviewPageItem.setVolume(overviewPageItem.audioPct + (event.angleDelta.y > 0 ? 4 : -4))
                        }
                    }

                    Text {
                        Layout.topMargin: Theme.spacingSM
                        text: "APPAREILS"
                        color: Theme.textMuted
                        font.pixelSize: 9
                        font.letterSpacing: 1
                        font.bold: true
                    }

                    Text {
                        visible: overviewPageItem.audioSinks.length === 0
                        text: "Chargement…"
                        color: Theme.textMuted
                        font.pixelSize: Theme.fontLabel
                    }

                    Repeater {
                        model: overviewPageItem.audioSinks

                        delegate: Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 38
                            radius: Theme.radiusSmall
                            readonly property bool isCurrent: modelData.name === overviewPageItem.audioSinkName
                            color: isCurrent ? Theme.accentMuted : (sinkHover.hovered ? Theme.surfaceHover : "transparent")
                            border.width: isCurrent ? 1 : 0
                            border.color: Theme.accent

                            Behavior on color { ColorAnimation { duration: Theme.durationFast } }

                            Text {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                text: modelData.desc
                                color: isCurrent ? Theme.textPrimary : Theme.textSecondary
                                font.pixelSize: Theme.fontBody
                                elide: Text.ElideRight
                            }

                            HoverHandler { id: sinkHover }
                            TapHandler { onTapped: overviewPageItem.selectSink(modelData.name) }
                        }
                    }
                }
            }
        }

        // -- Popup Wi-Fi (v16) — même mécanique/emplacement que le popup
        // audio ci-dessus (overlay plein panneau, scrim, TapHandler pour
        // fermer, animation fondu+scale identique). État/actions lus sur
        // `overviewPageItem` : wifiPickerOpen/wifiEnabled/wifiScanning/
        // wifiNetworks/wifiExpandedSsid/wifiPwDraft/wifiStatusText +
        // openWifiPicker/closeWifiPicker/wifiRescan/toggleWifiExpand/
        // connectWifi/setWifiEnabled.
        Rectangle {
            id: wifiScrim
            anchors.fill: parent
            radius: parent.radius
            color: Qt.rgba(0, 0, 0, 0.55)
            visible: opacity > 0
            opacity: overviewPageItem.wifiPickerOpen ? 1 : 0

            Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

            TapHandler { onTapped: overviewPageItem.closeWifiPicker() }

            Rectangle {
                id: wifiPopup
                anchors.centerIn: parent
                width: parent.width - Theme.spacingLG * 2
                implicitHeight: Math.min(wifiCol.implicitHeight + Theme.spacingLG * 2, panel.height - Theme.spacingLG * 2)
                radius: Theme.radiusLarge
                color: Theme.surface
                border.width: 1
                border.color: Theme.accent
                scale: 0.9 + 0.1 * wifiScrim.opacity
                transformOrigin: Item.Center
                clip: true

                MouseArea { anchors.fill: parent; onClicked: {} }

                Flickable {
                    id: wifiFlick
                    anchors.fill: parent
                    anchors.margins: Theme.spacingLG
                    clip: true
                    contentWidth: width
                    contentHeight: wifiCol.implicitHeight
                    boundsBehavior: Flickable.StopAtBounds

                    ColumnLayout {
                        id: wifiCol
                        width: wifiFlick.width
                        spacing: Theme.spacingMD

                        // Header : icône badge + titre + toggle on/off,
                        // même pattern que le header du popup audio.
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Theme.spacingSM

                            Rectangle {
                                implicitWidth: 26
                                implicitHeight: 26
                                radius: Theme.radiusSmall
                                color: Theme.accentMuted
                                border.width: 1
                                border.color: Theme.accent
                                Icon {
                                    anchors.centerIn: parent
                                    name: "wifi"
                                    color: Theme.accent
                                    implicitWidth: 14
                                    implicitHeight: 14
                                }
                            }
                            Text {
                                text: "Wi-Fi"
                                color: Theme.textPrimary
                                font.pixelSize: Theme.fontBody
                                font.bold: true
                                Layout.fillWidth: true
                            }
                            Toggle {
                                checked: overviewPageItem.wifiEnabled
                                onToggled: (state) => overviewPageItem.setWifiEnabled(state)
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.topMargin: Theme.spacingSM

                            Text {
                                text: "RÉSEAUX"
                                color: Theme.textMuted
                                font.pixelSize: 9
                                font.letterSpacing: 1
                                font.bold: true
                                Layout.fillWidth: true
                            }
                            Text {
                                text: overviewPageItem.wifiScanning ? "…" : "↻"
                                color: Theme.accent
                                font.pixelSize: 13
                                MouseArea {
                                    anchors.fill: parent
                                    anchors.margins: -6
                                    enabled: overviewPageItem.wifiEnabled
                                    onClicked: overviewPageItem.wifiRescan()
                                }
                            }
                        }

                        Text {
                            visible: !overviewPageItem.wifiEnabled
                            text: "Wi-Fi désactivé"
                            color: Theme.textMuted
                            font.pixelSize: Theme.fontLabel
                        }

                        Text {
                            visible: overviewPageItem.wifiEnabled && overviewPageItem.wifiNetworks.length === 0
                            text: overviewPageItem.wifiScanning ? "Scan en cours…" : "Aucun réseau détecté."
                            color: Theme.textMuted
                            font.pixelSize: Theme.fontLabel
                        }

                        Repeater {
                            model: overviewPageItem.wifiEnabled ? overviewPageItem.wifiNetworks : []

                            delegate: ColumnLayout {
                                id: netRow
                                Layout.fillWidth: true
                                spacing: 6

                                // Capturé en dehors du Repeater imbriqué des
                                // barres de signal : dans un Repeater
                                // imbriqué, `modelData`/`index` du repeater
                                // enfant masquent ceux du parent — il faut
                                // une propriété nommée pour y accéder depuis
                                // l'intérieur.
                                readonly property int netSignal: modelData.signal
                                readonly property bool netActive: modelData.active
                                readonly property string netSsid: modelData.ssid
                                readonly property string netSecurity: modelData.security

                                Rectangle {
                                    Layout.fillWidth: true
                                    implicitHeight: 38
                                    radius: Theme.radiusSmall
                                    color: netRow.netActive ? Theme.accentMuted : (netRowHover.hovered ? Theme.surfaceHover : "transparent")
                                    border.width: netRow.netActive ? 1 : 0
                                    border.color: Theme.accent

                                    Behavior on color { ColorAnimation { duration: Theme.durationFast } }

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 10
                                        anchors.rightMargin: 10
                                        spacing: 8

                                        Icon {
                                            visible: netRow.netSecurity !== "--"
                                            name: "lock"
                                            color: netRow.netActive ? Theme.textPrimary : Theme.textSecondary
                                            implicitWidth: 11
                                            implicitHeight: 11
                                        }
                                        Text {
                                            text: netRow.netSsid
                                            color: netRow.netActive ? Theme.textPrimary : Theme.textSecondary
                                            font.pixelSize: Theme.fontBody
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                        }

                                        // Barres de signal — 4 crans, remplis
                                        // selon le %, pas de dégradé/glow
                                        // (règle du projet), juste rempli/
                                        // vide en accent/border.
                                        Row {
                                            spacing: 2
                                            Layout.alignment: Qt.AlignVCenter
                                            Repeater {
                                                model: 4
                                                delegate: Rectangle {
                                                    width: 3
                                                    height: 4 + index * 3
                                                    anchors.bottom: parent ? parent.bottom : undefined
                                                    radius: 1
                                                    color: (index + 1) <= Math.ceil((netRow.netSignal / 100) * 4)
                                                        ? Theme.accent : Theme.border
                                                }
                                            }
                                        }

                                        Text {
                                            text: netRow.netActive ? "Connecté" : ""
                                            color: Theme.accent
                                            font.pixelSize: Theme.fontLabel
                                            visible: netRow.netActive
                                        }
                                    }

                                    HoverHandler { id: netRowHover }
                                    TapHandler {
                                        onTapped: {
                                            if (netRow.netActive) return
                                            if (netRow.netSecurity === "--") {
                                                overviewPageItem.connectWifi(netRow.netSsid, netRow.netSecurity, "")
                                            } else {
                                                overviewPageItem.toggleWifiExpand(netRow.netSsid)
                                            }
                                        }
                                    }
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    Layout.leftMargin: 10
                                    visible: overviewPageItem.wifiExpandedSsid === netRow.netSsid
                                    spacing: 8

                                    TextField {
                                        id: wifiPwField
                                        Layout.fillWidth: true
                                        echoMode: TextInput.Password
                                        placeholderText: "Mot de passe"
                                        color: Theme.textPrimary
                                        font.pixelSize: Theme.fontBody
                                        background: Rectangle { color: Theme.background; radius: Theme.radiusSmall; border.width: 1; border.color: Theme.border }
                                        onTextChanged: overviewPageItem.wifiPwDraft = text
                                    }

                                    Rectangle {
                                        width: 90
                                        height: 30
                                        radius: Theme.radiusSmall
                                        color: Theme.accent
                                        Text {
                                            anchors.centerIn: parent
                                            text: "Connecter"
                                            color: Theme.background
                                            font.pixelSize: Theme.fontLabel
                                            font.bold: true
                                        }
                                        TapHandler {
                                            onTapped: {
                                                overviewPageItem.connectWifi(netRow.netSsid, netRow.netSecurity, wifiPwField.text)
                                                overviewPageItem.wifiExpandedSsid = ""
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Text {
                            visible: overviewPageItem.wifiStatusText.length > 0
                            text: overviewPageItem.wifiStatusText
                            color: Theme.accent
                            font.pixelSize: Theme.fontLabel
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                    }
                }
            }
        }
    }
}
