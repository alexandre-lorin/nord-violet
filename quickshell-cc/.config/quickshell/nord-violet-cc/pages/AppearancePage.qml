import QtQuick
import QtQuick.Layouts
import "../theme"
import "../components"
import ".." as Root

ColumnLayout {
    id: root
    spacing: 8
    signal toastRequested(string message)

    StatusCard {
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6
            Text { text: "[ NORD VIOLET / STYLE ]"; color: Theme.accent; font.family: "JetBrains Mono"; font.pixelSize: 9; font.bold: true; font.letterSpacing: 1.5 }
            Text { text: "ATELIER SOMBRE"; color: Theme.textPrimary; font.family: "JetBrains Mono"; font.pixelSize: 16 }
            Text { Layout.fillWidth: true; text: "accent synchronisé · surfaces mates · mouvement court"; color: Theme.textMuted; font.family: "JetBrains Mono"; font.pixelSize: Theme.fontLabel; wrapMode: Text.WordWrap }
        }
    }

    GridLayout {
        Layout.topMargin: 14
        Layout.fillWidth: true
        columns: 1
        columnSpacing: Theme.spacingMD
        rowSpacing: Theme.spacingMD

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            spacing: Theme.spacingXS
            SectionHeader { text: "PALETTE"; first: true }
            SettingsCard {
                SelectRow {
                    label: "Couleur d’accent"
                    model: Root.Colors.accentPresets.map(function(p) { return { label: p.name, color: p.value } })
                    currentValue: Root.Colors.accent
                    showDivider: false
                    onSelected: function(value) {
                        Root.Colors.setAccent(value)
                        root.toastRequested("Accent appliqué au bureau")
                    }
                }
            }
            Text { Layout.fillWidth: true; Layout.topMargin: 5; text: "L’accent est appliqué au shell, à Waybar, au terminal et aux notifications."; color: Theme.textMuted; font.pixelSize: Theme.fontLabel; wrapMode: Text.WordWrap }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            spacing: Theme.spacingXS
            SectionHeader { text: "SYSTÈME VISUEL"; first: true }
            SettingsCard {
                SelectRow {
                    label: "Densité des menus (interface)"
                    model: [
                        { label: "Compacte", value: "compact" },
                        { label: "Équilibrée", value: "balanced" },
                        { label: "Aérée", value: "airy" }
                    ]
                    currentValue: Preferences.density
                    onSelected: function(value) {
                        Preferences.setDensity(value)
                        root.toastRequested("Densité appliquée")
                    }
                }
                SelectRow {
                    label: "Angles"
                    model: [
                        { label: "Nets", value: "sharp" },
                        { label: "Modérés", value: "moderate" },
                        { label: "Doux", value: "soft" }
                    ]
                    currentValue: Preferences.corners
                    onSelected: function(value) {
                        Preferences.setCorners(value)
                        root.toastRequested("Angles appliqués")
                    }
                }
                SelectRow {
                    label: "Animations"
                    model: [
                        { label: "Coupées", value: "off" },
                        { label: "Réduites", value: "reduced" },
                        { label: "Complètes", value: "full" }
                    ]
                    currentValue: Preferences.motion
                    showDivider: false
                    onSelected: function(value) {
                        Preferences.setMotion(value)
                        root.toastRequested("Animations mises à jour")
                    }
                }
            }
        }
    }


    Item { Layout.fillHeight: true }
}
