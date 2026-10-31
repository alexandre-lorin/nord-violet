import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import "../theme"
import "../components"

ColumnLayout {
    id: root
    spacing: 8

    property var wallpapers: []
    property string selectedPath: ""
    property string currentPath: ""
    property string targetMonitor: "all"
    property string statusText: ""

    readonly property string wallDir: "/home/toubi/.config/hypr/wallpaper"
    readonly property string applyScript: "/home/toubi/.config/quickshell/nord-violet-cc/scripts/wallpaperctl.py"

    function fileName(path) {
        var parts = path.split("/")
        return parts.length ? parts[parts.length - 1] : path
    }

    Component.onCompleted: {
        listProc.running = true
        configProc.running = true
    }

    Process {
        id: listProc
        command: ["find", "-L", root.wallDir, "-maxdepth", "1", "-type", "f", "-print"]
        stdout: StdioCollector {
            onStreamFinished: {
                var accepted = [".png", ".jpg", ".jpeg", ".webp"]
                root.wallpapers = text.trim().split("\n").filter(function(path) {
                    var lower = path.toLowerCase()
                    return path.length > 0 && accepted.some(function(ext) { return lower.endsWith(ext) })
                }).sort()
                if (!root.selectedPath && root.currentPath)
                    root.selectedPath = root.currentPath
                if (!root.selectedPath && root.wallpapers.length)
                    root.selectedPath = root.wallpapers[0]
            }
        }
    }

    Process {
        id: configProc
        command: ["cat", "/home/toubi/.config/hypr/hyprpaper.conf"]
        stdout: StdioCollector {
            onStreamFinished: {
                var match = text.match(/^\s*preload\s*=\s*(.+)$/m)
                if (!match) match = text.match(/^\s*path\s*=\s*(.+)$/m)
                root.currentPath = match ? match[1].trim() : ""
                if (!root.selectedPath) root.selectedPath = root.currentPath
            }
        }
    }

    Process {
        id: applyProc
        stdout: StdioCollector {
            onStreamFinished: {
                root.currentPath = text.trim()
                root.statusText = "Fond d’écran appliqué et enregistré."
            }
        }
        stderr: StdioCollector {
            onStreamFinished: if (text.trim().length) root.statusText = "Échec : " + text.trim()
        }
        onExited: if (exitCode !== 0 && root.statusText.length === 0) root.statusText = "Impossible d’appliquer ce fond."
    }

    Process {
        id: randomProc
        stdout: StdioCollector {
            onStreamFinished: {
                var path = text.trim()
                if (path.length) {
                    root.currentPath = path
                    root.selectedPath = path
                    root.statusText = "Fond aléatoire appliqué."
                }
            }
        }
        stderr: StdioCollector {
            onStreamFinished: if (text.trim().length) root.statusText = "Échec : " + text.trim()
        }
    }

    Process {
        id: pickerProc
        command: [
            "zenity", "--file-selection", "--title=Importer un fond d’écran",
            "--file-filter=Images | *.png *.jpg *.jpeg *.webp"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                var path = text.trim()
                if (!path.length) return
                root.statusText = "Import en cours…"
                importProc.command = [root.applyScript, "import", path]
                importProc.running = true
            }
        }
    }

    Process {
        id: importProc
        stdout: StdioCollector {
            onStreamFinished: {
                var path = text.trim()
                if (!path.length) return
                root.selectedPath = path
                root.statusText = "Image importée."
                listProc.running = true
            }
        }
        stderr: StdioCollector {
            onStreamFinished: if (text.trim().length) root.statusText = "Échec : " + text.trim()
        }
    }

    SectionHeader { text: "BIBLIOTHÈQUE"; first: true }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: galleryColumn.implicitHeight + Theme.spacingMD * 2
        radius: 2
        color: "#0e1015"
        border.width: 1
        border.color: Theme.border

        ColumnLayout {
            id: galleryColumn
            anchors.fill: parent
            anchors.margins: Theme.spacingMD
            spacing: Theme.spacingMD

            GridLayout {
                Layout.fillWidth: true
                columns: width >= 720 ? 3 : 2
                columnSpacing: Theme.spacingSM
                rowSpacing: Theme.spacingSM

                Repeater {
                    model: root.wallpapers

                    delegate: Rectangle {
                        required property string modelData
                        Layout.fillWidth: true
                        Layout.preferredHeight: 132
                        radius: 2
                        color: Theme.background
                        border.width: root.selectedPath === modelData ? 2 : 1
                        border.color: root.selectedPath === modelData ? Theme.accent : Theme.border
                        clip: true

                        Image {
                            anchors.fill: parent
                            anchors.margins: 3
                            source: "file://" + modelData
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: true
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            height: 34
                            color: "#cc09090d"
                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width - 20
                                text: root.fileName(modelData)
                                color: Theme.textPrimary
                                font.pixelSize: Theme.fontLabel
                                font.family: "JetBrains Mono"
                                elide: Text.ElideMiddle
                            }
                        }

                        Rectangle {
                            visible: root.currentPath === modelData
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.margins: 8
                            width: currentLabel.implicitWidth + 12
                            height: 22
                            radius: 2
                            color: Theme.accent
                            Text {
                                id: currentLabel
                                anchors.centerIn: parent
                                text: "ACTUEL"
                                color: Theme.background
                                font.pixelSize: 9
                                font.family: "JetBrains Mono"
                                font.bold: true
                            }
                        }

                        TapHandler { onTapped: root.selectedPath = modelData }
                    }
                }
            }

            Text {
                visible: root.wallpapers.length === 0
                Layout.fillWidth: true
                text: "Aucune image dans ~/.config/hypr/wallpaper"
                color: Theme.textMuted
                font.pixelSize: Theme.fontBody
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.spacingSM

        Rectangle {
            implicitWidth: importLabel.implicitWidth + 24
            implicitHeight: 34
            radius: 2
            color: importHover.hovered ? Theme.surfaceHover : Theme.surface
            border.width: 1
            border.color: Theme.border
            Text {
                id: importLabel
                anchors.centerIn: parent
                text: "[ + ] Importer"
                color: Theme.textPrimary
                font.pixelSize: Theme.fontLabel
                font.family: "JetBrains Mono"
            }
            HoverHandler { id: importHover }
            TapHandler { onTapped: if (!pickerProc.running) pickerProc.running = true }
        }

        Item { Layout.fillWidth: true }

        Rectangle {
            implicitWidth: randomLabel.implicitWidth + 24
            implicitHeight: 34
            radius: 2
            color: randomHover.hovered ? Theme.accentMuted : Theme.surface
            border.width: 1
            border.color: randomHover.hovered ? Theme.accent : Theme.border
            Text {
                id: randomLabel
                anchors.centerIn: parent
                text: "[ RANDOM ]"
                color: Theme.textPrimary
                font.pixelSize: Theme.fontLabel
                font.family: "JetBrains Mono"
            }
            HoverHandler { id: randomHover }
            TapHandler {
                onTapped: {
                    if (randomProc.running) return
                    root.statusText = "Sélection aléatoire…"
                    randomProc.command = [root.applyScript, "random", root.targetMonitor]
                    randomProc.running = true
                }
            }
        }
    }

    SectionHeader { text: "APPLICATION" }

    SettingsCard {
        SelectRow {
            label: "Écrans ciblés"
            model: [
                { label: "Tous", value: "all" },
                { label: "HDMI-A-1", value: "HDMI-A-1" },
                { label: "eDP-1", value: "eDP-1" }
            ]
            currentValue: root.targetMonitor
            onSelected: function(value) { root.targetMonitor = value }
        }

        RowButton {
            label: "Appliquer le fond sélectionné"
            value: root.selectedPath ? root.fileName(root.selectedPath) : "Aucune sélection"
            showDivider: false
            onClicked: {
                if (!root.selectedPath || applyProc.running) return
                root.statusText = "Application en cours…"
                applyProc.command = [root.applyScript, root.selectedPath, root.targetMonitor]
                applyProc.running = true
            }
        }
    }

    Text {
        Layout.fillWidth: true
        visible: root.statusText.length > 0
        text: root.statusText
        color: root.statusText.indexOf("Échec") === 0 ? Theme.danger : Theme.textSecondary
        font.pixelSize: Theme.fontLabel
        wrapMode: Text.WordWrap
    }


    Item { Layout.fillHeight: true }
}
