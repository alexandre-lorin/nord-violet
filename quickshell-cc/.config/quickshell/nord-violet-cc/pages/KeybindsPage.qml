import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import "../theme"
import "../components"

// v32 — RÉELLE : lit et parse ~/.config/hypr/keybinds.conf à chaque
// ouverture de la page (`cat`, lecture seule), pas une liste recopiée
// à la main qui se périmera au premier bind ajouté/modifié. Groupé par
// les en-têtes "# --- Section ---" déjà présents dans le fichier.
//
// EXCEPTION volontaire : les blocs `code:NN` (changement/déplacement de
// fenêtre vers un bureau, SUPER+1..0 et CTRL+SUPER+1..0) ne sont PAS
// affichés ligne par ligne — 40 lignes quasi identiques n'apportent
// rien dans une UI de réglages. Un seul résumé (`_workspaceSummaryRows`
// ci-dessous) les remplace. Tout le reste vient du parsing réel.
ColumnLayout {
    id: root
    spacing: 8

    property var groups: []   // [{ section, binds: [{ keys, action }] }]
    property string filterText: ""

    readonly property var _workspaceSummaryRows: [
        { keys: "SUPER + 1…0", action: "Aller au bureau N (1-5 = écran principal, 6-0 = écran secondaire)" },
        { keys: "CTRL SUPER + 1…0", action: "Déplacer la fenêtre active vers le bureau N" }
    ]

    Component.onCompleted: readProc.running = true

    Process {
        id: readProc
        command: ["cat", "/home/toubi/.config/hypr/keybinds.conf"]
        stdout: StdioCollector {
            onStreamFinished: root.groups = root._parse(text)
        }
    }

    function _humanMods(raw) {
        return raw.trim().length > 0 ? raw.trim().replace("$mainMod", "SUPER") : "—"
    }

    function _humanAction(raw, key) {
        var value = raw.trim()
        var media = {XF86AudioRaiseVolume: "Augmenter le volume", XF86AudioLowerVolume: "Baisser le volume", XF86AudioMute: "Couper / rétablir le son", XF86MonBrightnessUp: "Augmenter la luminosité", XF86MonBrightnessDown: "Baisser la luminosité"}
        if (media[key]) return media[key]
        var known = [
            [/^killactive/, "Fermer la fenêtre active"],
            [/^fullscreen/, "Basculer le plein écran"],
            [/^movefocus,\s*l/, "Focus vers la gauche"],
            [/^movefocus,\s*r/, "Focus vers la droite"],
            [/^movefocus,\s*u/, "Focus vers le haut"],
            [/^movefocus,\s*d/, "Focus vers le bas"],
            [/^movewindow,\s*l/, "Déplacer la fenêtre à gauche"],
            [/^movewindow,\s*r/, "Déplacer la fenêtre à droite"],
            [/^movewindow,\s*u/, "Déplacer la fenêtre vers le haut"],
            [/^movewindow,\s*d/, "Déplacer la fenêtre vers le bas"],
            [/^resizeactive/, "Redimensionner la fenêtre"],
            [/^exec,\s*alacritty$/, "Ouvrir le terminal"],
            [/^exec,\s*thunar$/, "Ouvrir les fichiers"],
            [/omni-launcher/, "Ouvrir le lanceur"],
            [/omni-clipboard/, "Historique du presse-papiers"],
            [/omni-windows/, "Changer de fenêtre"],
            [/omni-emoji/, "Choisir un emoji"],
            [/ipc call cc toggle/, "Ouvrir le Control Center"],
            [/ipc call settings toggle/, "Ouvrir les Réglages"],
            [/focusctl\.sh/, "Basculer une session Focus"],
            [/settings page profiles/, "Ouvrir les profils"],
            [/hyprlock/, "Verrouiller la session"],
            [/wlogout/, "Ouvrir le menu d’alimentation"],
            [/swappy-region/, "Capture d’une zone"],
            [/swappy-fullscreen/, "Capture de l’écran complet"],
            [/swappy-monitor/, "Capture du moniteur"],
            [/toggle-app\.sh discord/, "Afficher Discord"],
            [/class scratchterm/, "Afficher le terminal scratchpad"],
            [/class monitoring/, "Afficher le monitoring"],
            [/falcon-popup/, "Afficher Falcon"],
            [/idle-toggle/, "Basculer l’inactivité automatique"],
            [/togglefloating/, "Basculer la fenêtre flottante"],
        ]
        for (var i = 0; i < known.length; i++) if (known[i][0].test(value)) return known[i][1]
        return value.replace(/^exec,\s*/, "")
    }

    function _filteredGroups() {
        var query = filterText.trim().toLowerCase()
        if (!query.length) return groups
        var result = []
        for (var i = 0; i < groups.length; i++) {
            var binds = groups[i].binds.filter(function(bind) {
                return (bind.keys + " " + bind.action).toLowerCase().indexOf(query) >= 0
            })
            if (binds.length) result.push({ section: groups[i].section, binds: binds })
        }
        return result
    }

    function _parse(text) {
        var lines = text.split("\n")
        var groups = []
        var current = null
        var skippedWorkspaceBlock = false

        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim()

            // v35 (relecture) : ton en-tête "Workspaces" est coupé sur 2
            // lignes dans le vrai fichier ("# --- Workspaces / "bureaux"
            // (cf. ... par\n# app, cf. ...) ---") — l'ancien regex exigeait
            // la fermeture "---" sur la MÊME ligne, donc cette section
            // n'était jamais reconnue, et le résumé SUPER+1…0 atterrissait
            // silencieusement dans la section précédente ("System").
            // Fix : n'exige plus de "---" fermant sur la même ligne,
            // juste l'ouvrant — et coupe le titre au premier "(" ou """
            // pour rester lisible (le reste de la phrase, coupée ou pas,
            // n'apporte rien dans un SectionHeader).
            var sectionMatch = line.match(/^#\s*---\s*(.+)$/)
            if (sectionMatch) {
                var title = sectionMatch[1].replace(/-{2,}\s*$/, "").trim()
                var cut = title.search(/[("]/)
                if (cut > 2) title = title.substring(0, cut).trim()
                title = title.replace(/[\s/]+$/, "")
                if (title.length > 40) title = title.substring(0, 40).trim() + "…"
                if (title.length > 0) {
                    current = { section: title, binds: [] }
                    groups.push(current)
                    skippedWorkspaceBlock = false
                }
                continue
            }

            var bindMatch = line.match(/^bind[lm]?\s*=\s*(.+)$/)
            if (!bindMatch || !current) continue

            // Découpe seulement les 2 premières virgules (MODS, KEY,
            // reste) — le "reste" peut contenir des virgules à lui
            // (ex. arguments hyprctl --batch), un split(",") global les
            // casserait.
            var rest = bindMatch[1]
            var firstComma = rest.indexOf(",")
            var secondComma = rest.indexOf(",", firstComma + 1)
            if (firstComma < 0 || secondComma < 0) continue

            var mods = rest.substring(0, firstComma).trim()
            var key = rest.substring(firstComma + 1, secondComma).trim()
            var action = rest.substring(secondComma + 1).trim()

            if (key.indexOf("code:") === 0) {
                if (!skippedWorkspaceBlock) {
                    skippedWorkspaceBlock = true
                    root._workspaceSummaryRows.forEach(function (r) { current.binds.push(r) })
                }
                continue
            }

            // v35 (relecture) : quand MODS est vide (touches XF86
            // volume/luminosité, ex. `bindl = , XF86AudioRaiseVolume,
            // ...`), l'ancien code affichait quand même "—" collé à la
            // touche sans espace ("—XF86AudioRaiseVolume") — 6 vraies
            // lignes du fichier touchées, jamais vues tourner avant
            // cette relecture. Fix : pas de "—" du tout quand il n'y a
            // pas de modificateur, juste la touche seule.
            var modsDisplay = mods.length > 0 ? (root._humanMods(mods) + " + ") : ""
            var keyLabels = {XF86AudioRaiseVolume: "Volume +", XF86AudioLowerVolume: "Volume −", XF86AudioMute: "Muet", XF86MonBrightnessUp: "Luminosité +", XF86MonBrightnessDown: "Luminosité −"}
            current.binds.push({ keys: modsDisplay + (keyLabels[key] || key), action: root._humanAction(action, key) })
        }

        return groups.filter(function (g) { return g.binds.length > 0 })
    }

    Rectangle {
        Layout.fillWidth: true; Layout.preferredHeight: 66
        radius: 2; color: Theme.surface; border.width: 1; border.color: Theme.border
        TextField {
            anchors.fill: parent; anchors.margins: 10
            placeholderText: "Rechercher une touche ou une action"
            placeholderTextColor: Theme.textMuted; color: Theme.textPrimary; font.pixelSize: Theme.fontBody
            background: Rectangle { radius: Theme.radiusSmall; color: Theme.background; border.width: 1; border.color: parent.activeFocus ? Theme.accent : Theme.border }
            onTextChanged: root.filterText = text
        }
    }

    SectionHeader { text: "RACCOURCIS CLAVIER" }

    Text {
        Layout.fillWidth: true
        visible: root.groups.length === 0
        text: "Lecture de keybinds.conf…"
        color: Theme.textMuted
        font.pixelSize: Theme.fontLabel
    }

    Repeater {
        model: root._filteredGroups()

        // Repeater imbriqué juste en dessous (une carte par groupe, une
        // row par bind) : `modelData`/`index` du Repeater enfant
        // masquent ceux de celui-ci une fois à l'intérieur — même piège
        // que documenté dans ControlCenter.qml pour la liste Wi-Fi.
        // Fix identique : une propriété nommée (`groupData`) capturée
        // ici, référencée explicitement par id depuis l'intérieur du
        // Repeater enfant au lieu de compter sur `modelData` implicite.
        delegate: ColumnLayout {
            id: groupDelegate
            readonly property var groupData: modelData

            Layout.fillWidth: true
            spacing: 0

            SectionHeader { text: groupDelegate.groupData.section.toUpperCase() }

            SettingsCard {
                Repeater {
                    model: groupDelegate.groupData.binds

                    delegate: RowButton {
                        label: modelData.action
                        value: modelData.keys
                        showDivider: index < groupDelegate.groupData.binds.length - 1
                    }
                }
            }
        }
    }

    Item { Layout.fillHeight: true }
}
