import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import "theme"
import "pages" as Pages

Window {
    id: settings
    // Atelier V2 : navigation par usages et actions contextuelles.
    title: "Nord Violet - Réglages"
    visible: false
    color: "transparent"
    minimumWidth: 900
    minimumHeight: 600

    Component.onCompleted: {
        width = 1180
        height = 760
    }

    signal backRequested()

    property string currentKey: "overview"
    property string searchText: ""
    property bool advancedVisible: true
    property int pendingChanges: 0
    property string pendingLabel: ""
    property string toastMessage: ""

    function focusSearch() {
        searchField.forceActiveFocus()
        searchField.selectAll()
    }

    function handleKey(event) {
        if (event.key === Qt.Key_Escape) {
            settings.visible = false
            event.accepted = true
        } else if (event.key === Qt.Key_K && event.modifiers === Qt.ControlModifier) {
            focusSearch()
            event.accepted = true
        } else if (event.key === Qt.Key_Slash &&
                   !(event.modifiers & (Qt.ControlModifier | Qt.AltModifier | Qt.MetaModifier)) &&
                   !(activeFocusItem && typeof activeFocusItem.text !== "undefined")) {
            focusSearch()
            event.accepted = true
        }
    }

    onVisibleChanged: { if (visible) keyboardRoot.forceActiveFocus() }

    function showToast(message) {
        toastMessage = message
        toastTimer.restart()
    }

    function stageChanges(count, label) {
        pendingChanges = Math.max(1, count)
        pendingLabel = label || "Modifications en attente"
    }

    function clearPending(applied) {
        pendingChanges = 0
        if (applied) showToast("Modifications appliquées")
    }

    readonly property var sections: [
        { key: "overview", label: "Vue générale", icon: "›", group: "Essentiel", description: "État live du bureau et commandes essentielles", keywords: "status état session matériel batterie audio luminosité", component: overviewComponent },
        { key: "style", label: "Style", icon: "✦", group: "Essentiel", description: "Palette, matière, typographie et mouvement", keywords: "thème couleur accent contraste police transparence apparence animation", component: styleComponent },
        { key: "wallpaper", label: "Fonds", icon: "▧", group: "Essentiel", description: "Bibliothèque, écrans et automatisation", keywords: "wallpaper image fond hyprpaper aléatoire palette", component: wallpaperComponent },
        { key: "desktop", label: "Bureau", icon: "▦", group: "Essentiel", description: "Barre, widgets, fenêtres et espaces", keywords: "barre waybar widget dock fenêtre workspace bureau", component: desktopComponent },
        { key: "profiles", label: "Profils", icon: "◇", group: "Workflow", description: "Travail, Nomade, Jeu et Nuit", keywords: "profil contexte focus travail nomade jeu nuit", component: profilesComponent },
        { key: "omni", label: "Omni", icon: "⌘", group: "Workflow", description: "Recherche, commandes, emoji et presse-papiers", keywords: "recherche commande emoji clipboard application fichier launcher", component: omniComponent },
        { key: "notifications", label: "Notifications", icon: "◌", group: "Workflow", description: "Actives, historique et restauration", keywords: "mako notification historique dnd restaurer", component: notificationsComponent },
        { key: "displays", label: "Écrans", icon: "▣", group: "Matériel", description: "Moniteurs et luminosité", keywords: "moniteur résolution fréquence hdmi edp luminosité", component: displayComponent },
        { key: "audio", label: "Son", icon: "◖", group: "Matériel", description: "Sorties, entrées et volumes", keywords: "audio volume micro sortie entrée pipewire", component: audioComponent },
        { key: "connections", label: "Connexions", icon: "⌁", group: "Matériel", description: "Wi-Fi et réseaux", keywords: "wifi réseau internet nmcli connexion", component: connectionsComponent },
        { key: "keybinds", label: "Raccourcis", icon: "⌘", group: "Système", description: "Combinaisons actives", keywords: "touches clavier super keybind hotkey", component: keybindsComponent },
        { key: "system", label: "Système", icon: "⚙", group: "Système", description: "Machine, ressources et maintenance", keywords: "mémoire ram disque noyau kernel uptime service maintenance", component: systemComponent },
        { key: "hyprland", label: "Hyprland", icon: "⋯", group: "Avancé", description: "Compositeur, workspaces et règles", keywords: "fenêtre règle workspace compositor version", component: hyprlandComponent, advanced: true }
    ]

    readonly property var visibleSections: sections.filter(function(section) {
        if (section.advanced && !advancedVisible) return false
        var query = searchText.trim().toLowerCase()
        if (!query.length) return true
        return (section.label + " " + section.description + " " + section.keywords).toLowerCase().indexOf(query) >= 0
    })

    readonly property var groups: ["Essentiel", "Workflow", "Matériel", "Système", "Avancé"]
    readonly property var currentSection: {
        for (var i = 0; i < sections.length; i++)
            if (sections[i].key === currentKey) return sections[i]
        return sections[0]
    }

    function sectionsForGroup(group) {
        return visibleSections.filter(function(section) { return section.group === group })
    }

    function navigate(key) {
        for (var i = 0; i < sections.length; i++) {
            if (sections[i].key === key) {
                currentKey = key
                return
            }
        }
    }

    Rectangle {
        id: keyboardRoot
        focus: true
        Keys.onPressed: event => settings.handleKey(event)
        anchors.fill: parent
        radius: 4
        color: Theme.background
        border.width: 1
        border.color: Theme.border
        clip: true

        RowLayout {
            anchors.fill: parent
            spacing: 0

            Rectangle {
                Layout.preferredWidth: 224
                Layout.fillHeight: true
                color: "#090a0e"

                Rectangle {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 1
                    color: Theme.border
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 0

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 8
                        Layout.rightMargin: 8
                        Layout.topMargin: 5
                        Layout.bottomMargin: 18
                        spacing: 10

                        Rectangle {
                            Layout.fillWidth: true
                            height: 32
                            color: "transparent"
                            Text {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                text: "NVCTL / SETTINGS"
                                color: Theme.accent
                                font.family: "JetBrains Mono"
                                font.pixelSize: 12
                                font.bold: true
                                font.letterSpacing: 1
                            }
                        }
                    }

                    TextField {
                        id: searchField
                        Layout.fillWidth: true
                        Layout.preferredHeight: 38
                        Layout.bottomMargin: 14
                        leftPadding: 12
                        rightPadding: 12
                        placeholderText: "Rechercher un réglage"
                        placeholderTextColor: Theme.textMuted
                        color: Theme.textPrimary
                        font.pixelSize: Theme.fontLabel
                        font.family: "JetBrains Mono"
                        selectByMouse: true
                        background: Rectangle {
                            radius: Theme.radiusSmall
                            color: Theme.surface
                            border.width: 1
                            border.color: searchField.activeFocus ? Theme.accent : Theme.border
                        }
                        onTextChanged: settings.searchText = text
                        Keys.priority: Keys.BeforeItem
                        Keys.onPressed: event => settings.handleKey(event)
                        onAccepted: {
                            if (settings.visibleSections.length > 0) {
                                settings.navigate(settings.visibleSections[0].key)
                                clear()
                                keyboardRoot.forceActiveFocus()
                            }
                        }
                    }

                    Flickable {
                        id: navFlick
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        contentWidth: width
                        contentHeight: navColumn.implicitHeight
                        boundsBehavior: Flickable.StopAtBounds
                        clip: true

                        ColumnLayout {
                            id: navColumn
                            width: navFlick.width
                            spacing: 0

                            Repeater {
                                model: settings.groups

                                delegate: ColumnLayout {
                                    required property string modelData
                                    readonly property var items: settings.sectionsForGroup(modelData)
                                    Layout.fillWidth: true
                                    visible: items.length > 0
                                    spacing: 3

                                    Text {
                                        Layout.leftMargin: 10
                                        Layout.topMargin: 9
                                        Layout.bottomMargin: 4
                                        text: modelData.toUpperCase()
                                        color: Theme.textMuted
                                        font.pixelSize: 9
                                        font.family: "JetBrains Mono"
                                        font.bold: true
                                        font.letterSpacing: 1.3
                                    }

                                    Repeater {
                                        model: parent.items

                                        delegate: Rectangle {
                                            required property var modelData
                                            Layout.fillWidth: true
                                            height: 36
                                            radius: 0
                                            color: settings.currentKey === modelData.key ? Theme.accentMuted : (navHover.hovered ? Theme.surface : "transparent")

                                            Rectangle {
                                                visible: settings.currentKey === modelData.key
                                                anchors.left: parent.left
                                                anchors.verticalCenter: parent.verticalCenter
                                                width: 2
                                                height: 20
                                                radius: 1
                                                color: Theme.accent
                                            }

                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.leftMargin: 11
                                                anchors.rightMargin: 10
                                                spacing: 10
                                                Text {
                                                    text: settings.currentKey === modelData.key ? "›" : "·"
                                                    color: settings.currentKey === modelData.key ? Theme.accent : Theme.textMuted
                                                    font.family: "JetBrains Mono"
                                                    font.pixelSize: 12
                                                    Layout.preferredWidth: 18
                                                    horizontalAlignment: Text.AlignHCenter
                                                }
                                                Text {
                                                    Layout.fillWidth: true
                                                    text: modelData.label
                                                    color: settings.currentKey === modelData.key ? Theme.textPrimary : Theme.textSecondary
                                                    font.pixelSize: Theme.fontBody
                                                    font.family: "JetBrains Mono"
                                                }
                                            }

                                            HoverHandler { id: navHover }
                                            TapHandler { onTapped: settings.currentKey = modelData.key }
                                        }
                                    }
                                }
                            }

                            Text {
                                visible: settings.visibleSections.length === 0
                                Layout.fillWidth: true
                                Layout.margins: 10
                                text: "Aucun résultat"
                                color: Theme.textMuted
                                font.pixelSize: Theme.fontLabel
                                wrapMode: Text.WordWrap
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: Theme.border
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 12
                        Layout.leftMargin: 4
                        Layout.rightMargin: 4
                        Text {
                            Layout.fillWidth: true
                            text: "Options avancées"
                            color: Theme.textMuted
                            font.pixelSize: Theme.fontLabel
                            font.family: "JetBrains Mono"
                        }
                        Rectangle {
                            width: 36
                            height: 20
                            radius: 2
                            color: settings.advancedVisible ? Theme.accent : Theme.surfaceHover
                            border.width: 1
                            border.color: settings.advancedVisible ? Theme.accent : Theme.border
                            Rectangle {
                                width: 14
                                height: 14
                                radius: 1
                                y: 2
                                x: settings.advancedVisible ? 19 : 2
                                color: settings.advancedVisible ? Theme.background : Theme.textMuted
                                Behavior on x { NumberAnimation { duration: Theme.durationFast } }
                            }
                            TapHandler { onTapped: settings.advancedVisible = !settings.advancedVisible }
                        }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 68
                    color: Theme.background

                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: 1
                        color: Theme.border
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        anchors.topMargin: 12
                        anchors.bottomMargin: 12
                        ColumnLayout {
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 6
                            Text {
                                text: "toubi@nord : ~/settings/" + settings.currentSection.key
                                color: Theme.textMuted
                                font.pixelSize: 10
                                font.family: "JetBrains Mono"
                            }
                            Text {
                                text: "› " + settings.currentSection.label.toUpperCase()
                                color: Theme.textPrimary
                                font.pixelSize: 14
                                font.family: "JetBrains Mono"
                                font.bold: true
                            }
                        }
                        Item { Layout.fillWidth: true }
                    }
                }

                Flickable {
                    id: contentFlick
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.leftMargin: 20
                    Layout.rightMargin: 20
                    Layout.topMargin: 20
                    Layout.bottomMargin: 16
                    contentWidth: width
                    contentHeight: contentColumn.implicitHeight
                    boundsBehavior: Flickable.StopAtBounds
                    clip: true

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                        width: 4
                        contentItem: Rectangle {
                            implicitWidth: 4
                            radius: 1
                            color: parent.pressed ? Theme.accent : Theme.border
                        }
                        background: Item {}
                    }

                    ColumnLayout {
                        id: contentColumn
                        width: contentFlick.width
                        spacing: 16

                        Text {
                            Layout.fillWidth: true
                            text: settings.currentSection.description
                            color: Theme.textMuted
                            font.pixelSize: 11
                            font.family: "JetBrains Mono"
                            wrapMode: Text.WordWrap
                        }

                        Loader {
                            id: pageLoader
                            Layout.fillWidth: true
                            sourceComponent: settings.currentSection.component
                            onLoaded: {
                                contentFlick.contentY = 0
                                if (item && "pollingActive" in item)
                                    item.pollingActive = Qt.binding(() => settings.visible)
                            }

                            Connections {
                                target: pageLoader.item
                                ignoreUnknownSignals: true
                                function onToastRequested(message) { settings.showToast(message) }
                                function onDraftRequested(count, label) { settings.stageChanges(count, label) }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    color: "#090a0e"
                    border.width: 1
                    border.color: Theme.border
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        Text { text: ":"; color: Theme.accent; font.family: "JetBrains Mono"; font.bold: true }
                        Text { text: "tapez / pour rechercher"; color: Theme.textMuted; font.family: "JetBrains Mono"; font.pixelSize: 10 }
                        Item { Layout.fillWidth: true }
                        Text { text: "Esc fermer  ·  Ctrl+K rechercher"; color: Theme.textMuted; font.family: "JetBrains Mono"; font.pixelSize: 10 }
                    }
                }
            }
        }
    }

        Rectangle {
            id: actionDock
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: settings.pendingChanges > 0 ? 18 : -70
            width: Math.min(510, parent.width - 40)
            height: 52
            radius: Theme.radiusMedium
            color: "#1a1a24"
            border.width: 1
            border.color: Theme.border
            visible: anchors.bottomMargin > -60
            z: 20

            Behavior on anchors.bottomMargin { NumberAnimation { duration: Theme.durationMedium; easing.type: Easing.OutCubic } }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Theme.spacingMD
                anchors.rightMargin: 8
                spacing: Theme.spacingSM
                Text {
                    Layout.fillWidth: true
                    text: settings.pendingChanges + (settings.pendingChanges > 1 ? " changements" : " changement") + (settings.pendingLabel.length ? " · " + settings.pendingLabel : "")
                    color: Theme.textSecondary
                    font.pixelSize: Theme.fontLabel
                    elide: Text.ElideRight
                }
                Rectangle {
                    width: 76; height: 34; radius: Theme.radiusSmall
                    color: discardHover.hovered ? Theme.surfaceHover : "transparent"
                    Text { anchors.centerIn: parent; text: "Annuler"; color: Theme.textSecondary; font.pixelSize: Theme.fontLabel }
                    HoverHandler { id: discardHover }
                    TapHandler { onTapped: settings.clearPending(false) }
                }
                Rectangle {
                    width: 86; height: 34; radius: Theme.radiusSmall
                    color: Theme.accent
                    Text { anchors.centerIn: parent; text: "Appliquer"; color: Theme.background; font.pixelSize: Theme.fontLabel; font.bold: true }
                    TapHandler { onTapped: settings.clearPending(true) }
                }
            }
        }

        Rectangle {
            id: toast
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: 20
            anchors.bottomMargin: toastTimer.running ? 20 : -60
            width: Math.min(330, toastText.implicitWidth + 100)
            height: 44
            radius: Theme.radiusSmall
            color: "#1a1a24"
            border.width: 1
            border.color: Theme.border
            z: 21
            Behavior on anchors.bottomMargin { NumberAnimation { duration: Theme.durationMedium; easing.type: Easing.OutCubic } }
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 8
                Text { id: toastText; Layout.fillWidth: true; text: settings.toastMessage; color: Theme.textPrimary; font.pixelSize: Theme.fontLabel; elide: Text.ElideRight }
                Text { text: "FERMER"; color: Theme.accent; font.pixelSize: 9; font.bold: true }
            }
            TapHandler { onTapped: toastTimer.stop() }
        }

        Timer { id: toastTimer; interval: 3200 }

    Component { id: styleComponent; Pages.AppearancePage {} }
    Component { id: overviewComponent; Pages.TerminalOverviewPage {} }
    Component { id: wallpaperComponent; Pages.WallpaperPage {} }
    Component { id: desktopComponent; Pages.DesktopPage {} }
    Component { id: profilesComponent; Pages.ProfilesPage {} }
    Component { id: omniComponent; Pages.OmniPage {} }
    Component { id: notificationsComponent; Pages.NotificationsPage {} }
    Component { id: displayComponent; Pages.DisplayPage {} }
    Component { id: audioComponent; Pages.AudioPage {} }
    Component { id: connectionsComponent; Pages.ConnectionsPage {} }
    Component { id: keybindsComponent; Pages.KeybindsPage {} }
    Component { id: systemComponent; Pages.SystemPage {} }
    Component { id: hyprlandComponent; Pages.HyprlandPage {} }
}
