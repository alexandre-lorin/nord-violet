import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Quickshell
import "theme"
import "components"
import "pages" as Pages

// v9 — fenêtre séparée pour les Réglages (ex-"settingsShellComponent" de
// ControlCenter.qml, à l'identique niveau contenu/logique, juste sortie
// de la Window popup pour devenir une app à part entière). Voir
// HANDOFF.md v9. Ouverte par :
//   - le bouton "Réglages ›" du popup (ControlCenter.openSettings(),
//     câblé dans shell.qml) ;
//   - IPC directe, indépendamment du popup : `qs -c nord-violet-cc ipc
//     call settings open` (utile pour un bouton waybar ou un bind
//     dédié, sans passer par le Control Center).
Window {
    id: settings
    title: "Nord Violet - Réglages"
    visible: false
    color: "transparent"

    // Comme dans ControlCenter.qml : valeur de DÉPART seulement, jamais
    // un binding permanent, sinon la fenêtre se re-force elle-même et
    // ignore tout redimensionnement venant de Hyprland (le vrai bug
    // "popup ne prend pas la bonne taille" trouvé en v9).
    minimumWidth: 720
    minimumHeight: 480
    Component.onCompleted: {
        width = 960
        height = 640
    }

    // Émis par "‹ Control Center" dans la sidebar ; câblé dans
    // shell.qml pour fermer cette fenêtre et rouvrir le popup.
    signal backRequested()

    property int currentIndex: 1
    onVisibleChanged: if (!visible) { currentIndex = 1; searchText = "" }

    readonly property var sections: [
        { idx: 1, label: "Apparence", group: "Réglages", component: appearanceComponent },
        { idx: 2, label: "Écrans", group: "Réglages", component: displayComponent },
        { idx: 3, label: "Son", group: "Réglages", component: audioComponent },
        { idx: 4, label: "Connexions", group: "Réglages", component: connectionsComponent },
        { idx: 5, label: "Système", group: "Avancé", component: systemComponent },
        { idx: 6, label: "Hyprland", group: "Avancé", component: hyprlandComponent },
        { idx: 7, label: "Raccourcis", group: "Avancé", component: keybindsComponent }
    ]

    property string searchText: ""
    readonly property var filteredSections: {
        var q = searchText.trim().toLowerCase()
        if (q.length === 0) return sections
        return sections.filter(function(s) { return s.label.toLowerCase().indexOf(q) >= 0 })
    }
    readonly property var reglagesSections: filteredSections.filter(function(s) { return s.group === "Réglages" })
    readonly property var avanceSections: filteredSections.filter(function(s) { return s.group === "Avancé" })

    readonly property string currentLabel: {
        for (var i = 0; i < sections.length; i++) if (sections[i].idx === currentIndex) return sections[i].label
        return ""
    }
    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusLarge
        color: Theme.background
        border.width: 1
        border.color: Theme.border
        clip: true

        RowLayout {
            anchors.fill: parent
            spacing: 0

            Rectangle {
                Layout.preferredWidth: 190
                Layout.fillHeight: true
                color: Theme.surface

                Rectangle {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 1
                    color: Theme.border
                }

                Flickable {
                    id: sidebarFlick
                    anchors.fill: parent
                    anchors.margins: Theme.spacingMD
                    contentWidth: width
                    contentHeight: sidebarCol.implicitHeight
                    boundsBehavior: Flickable.StopAtBounds

                    ColumnLayout {
                        id: sidebarCol
                        width: sidebarFlick.width
                        spacing: 2

                        Text {
                            text: "NORD VIOLET"
                            color: Theme.textPrimary
                            font.pixelSize: Theme.fontBody
                            font.bold: true
                            font.letterSpacing: -0.3
                        }

                        Text {
                            text: "Réglages"
                            color: Theme.textMuted
                            font.pixelSize: Theme.fontLabel
                            Layout.bottomMargin: Theme.spacingMD
                        }

                        TextField {
                            id: searchField
                            Layout.fillWidth: true
                            Layout.preferredHeight: 30
                            Layout.bottomMargin: Theme.spacingSM
                            font.pixelSize: Theme.fontLabel
                            color: Theme.textPrimary
                            placeholderText: "Rechercher…"
                            placeholderTextColor: Theme.textMuted
                            background: Rectangle {
                                radius: Theme.radiusSmall
                                color: Theme.surfaceHover
                                border.width: 1
                                border.color: Theme.border
                            }
                            leftPadding: 10
                            rightPadding: 10
                            onTextChanged: settings.searchText = text
                        }

                        // -- Retour vers le popup Control Center ------------
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.bottomMargin: Theme.spacingSM
                            height: 30
                            radius: Theme.radiusSmall
                            color: backHover.hovered ? Theme.surfaceHover : "transparent"

                            Behavior on color { ColorAnimation { duration: Theme.durationFast } }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 4
                                spacing: 6

                                Text {
                                    text: "‹"
                                    color: Theme.textMuted
                                    font.pixelSize: Theme.fontBody
                                    font.bold: true
                                }
                                Text {
                                    text: "Control Center"
                                    color: Theme.textSecondary
                                    font.pixelSize: Theme.fontLabel
                                }
                            }

                            HoverHandler { id: backHover }
                            TapHandler { onTapped: settings.backRequested() }
                        }

                        Repeater {
                            model: [
                                { title: "Réglages", items: settings.reglagesSections },
                                { title: "Avancé", items: settings.avanceSections }
                            ]

                            delegate: ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                visible: modelData.items.length > 0

                                Text {
                                    text: modelData.title.toUpperCase()
                                    color: Theme.textMuted
                                    font.pixelSize: 9
                                    font.letterSpacing: 1
                                    font.bold: true
                                    Layout.topMargin: Theme.spacingSM
                                    Layout.bottomMargin: 4
                                    Layout.leftMargin: 4
                                }

                                Repeater {
                                    model: modelData.items

                                    delegate: Rectangle {
                                        Layout.fillWidth: true
                                        height: 32
                                        radius: Theme.radiusSmall
                                        readonly property int realIndex: modelData.idx
                                        readonly property bool active: settings.currentIndex === realIndex
                                        color: active ? Theme.accentMuted : "transparent"
                                        border.width: active ? 1 : 0
                                        border.color: Theme.accent

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: 10
                                            anchors.rightMargin: 10
                                            spacing: 8

                                            Rectangle {
                                                width: 5
                                                height: 5
                                                radius: 2.5
                                                color: Theme.accent
                                                visible: parent.parent.active
                                            }

                                            Text {
                                                text: modelData.label
                                                color: parent.parent.active ? Theme.textPrimary : Theme.textSecondary
                                                font.pixelSize: Theme.fontBody
                                                Layout.fillWidth: true
                                                elide: Text.ElideRight
                                            }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: settings.currentIndex = parent.realIndex
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                MouseArea {
                    anchors.fill: sidebarFlick
                    acceptedButtons: Qt.NoButton
                    onWheel: event => {
                        var step = 40
                        var dy = event.angleDelta.y > 0 ? -step : step
                        sidebarFlick.contentY = Math.max(0, Math.min(
                            sidebarFlick.contentHeight - sidebarFlick.height,
                            sidebarFlick.contentY + dy
                        ))
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0

                RowLayout {
                    Layout.fillWidth: true
                    Layout.margins: Theme.spacingLG
                    Layout.bottomMargin: Theme.spacingMD

                    ColumnLayout {
                        spacing: 2
                        Text {
                            text: settings.currentLabel
                            color: Theme.textPrimary
                            font.pixelSize: Theme.fontTitle
                            font.bold: true
                            font.letterSpacing: -0.5
                        }
                        Text {
                            text: "Nord Violet Control Center"
                            color: Theme.textMuted
                            font.pixelSize: Theme.fontLabel
                        }
                    }

                    Item { Layout.fillWidth: true }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.leftMargin: Theme.spacingLG
                    Layout.rightMargin: Theme.spacingLG
                    Layout.bottomMargin: Theme.spacingLG

                    Flickable {
                        id: contentFlick
                        anchors.fill: parent
                        clip: true
                        contentWidth: width
                        contentHeight: pageLoader.height
                        boundsBehavior: Flickable.StopAtBounds

                        // v32 — petit fade au changement de page (avant :
                        // coupure sèche, le Loader swap sourceComponent
                        // instantanément). Pas un vrai crossfade
                        // ancien->nouveau (ça demanderait l'incubation
                        // asynchrone façon Caelestia Pages.qml, plus
                        // complexe pour un gain minime ici) — juste la
                        // nouvelle page qui apparaît en fondu plutôt
                        // qu'en un seul cadre.
                        Loader {
                            id: pageLoader
                            width: parent.width
                            height: Math.max(contentFlick.height, item ? item.implicitHeight : 0)
                            opacity: 1
                            sourceComponent: {
                                for (var i = 0; i < settings.sections.length; i++) {
                                    if (settings.sections[i].idx === settings.currentIndex) return settings.sections[i].component
                                }
                                return null
                            }

                            Behavior on opacity { NumberAnimation { duration: Theme.durationMedium; easing.type: Easing.OutCubic } }

                            Connections {
                                target: settings
                                function onCurrentIndexChanged() {
                                    pageLoader.opacity = 0
                                    pageFadeIn.restart()
                                }
                            }
                            Timer { id: pageFadeIn; interval: 10; onTriggered: pageLoader.opacity = 1 }
                        }
                    }

                    MouseArea {
                        anchors.fill: contentFlick
                        acceptedButtons: Qt.NoButton
                        onWheel: event => {
                            var step = 60
                            var dy = event.angleDelta.y > 0 ? -step : step
                            contentFlick.contentY = Math.max(0, Math.min(
                                contentFlick.contentHeight - contentFlick.height,
                                contentFlick.contentY + dy
                            ))
                        }
                    }
                }
            }
        }
    }

    Component { id: appearanceComponent; Pages.AppearancePage {} }
    Component { id: displayComponent; Pages.DisplayPage {} }
    Component { id: audioComponent; Pages.AudioPage {} }
    Component { id: connectionsComponent; Pages.ConnectionsPage {} }
    Component { id: systemComponent; Pages.SystemPage {} }
    Component { id: hyprlandComponent; Pages.HyprlandPage {} }
    Component { id: keybindsComponent; Pages.KeybindsPage {} }
}
