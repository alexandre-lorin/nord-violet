import QtQuick
import QtQuick.Layouts
import "../theme"

// Carte "hero" de la maquette éditoriale validée : un gros chiffre/état
// avec un libellé au-dessus, une sous-ligne en dessous, et soit une barre
// de progression (lecture seule), soit un slider draggable, soit un tag.
//
// FIX v2 (retour utilisateur : texte coupé en fenêtre étroite vs
// plein écran) : label/value/sub n'avaient pas d'`elide`, donc un texte
// trop long pour la largeur de la carte débordait/se faisait couper au
// clip du Rectangle plutôt que se tronquer proprement avec "…". Les 3
// Text ont maintenant `Layout.fillWidth: true` + `elide: Text.ElideRight`.
//
// NOUVEAU v2 : `interactive: true` transforme la barre en slider
// draggable (au lieu de lecture-seule) — émet `progressEdited(value)`
// (0..1) pendant le drag ET au clic. Utilisé pour le volume audio de la
// page Overview (retour : "j'aimerai que ce soit un slider").
//
// Usage :
//   HeroStat { label: "Audio output"; value: "72%"; sub: "Built-in Speakers"; progress: 0.72 }
//   HeroStat { ...; interactive: true; onProgressEdited: (v) => setVolume(v) }
Rectangle {
    id: root
    Layout.fillWidth: true
    implicitHeight: content.implicitHeight + 20
    radius: 2
    color: "#0e1015"
    border.width: 1
    border.color: Theme.border
    clip: true

    property string label: ""
    property string value: ""
    property string sub: ""
    // v14 : ligne méta optionnelle sous sub (ex. débit réseau) — vide
    // par défaut, aucune carte existante affectée.
    property string meta: ""
    // v12 : sous-ligne cliquable (ex. changer de sortie audio) — reste
    // false par défaut, donc aucune carte existante n'est affectée sauf
    // si explicitement activée.
    property bool subClickable: false
    // v14 : toute la carte devient tapable (ex. ouvrir un popup) — les
    // zones qui ont déjà leur propre handler (slider, sous-ligne) le
    // gardent prioritaire, ceci ne capte que le reste de la carte.
    property bool cardClickable: false
    // -1 = pas de barre affichée ; sinon 0..1
    property real progress: -1
    property bool interactive: false
    // Utilisé pour le petit texte à droite (ex: état "On"/"Secure"),
    // remplace la barre si non vide.
    property string tag: ""

    signal progressEdited(real value)
    signal subTapped()
    signal cardTapped()

    TapHandler {
        enabled: root.cardClickable
        onTapped: root.cardTapped()
    }

    // Molette = ajuste la valeur par pas de 4%, activable dès qu'un
    // slider interactif est affiché (indépendant de cardClickable).
    WheelHandler {
        enabled: root.interactive && root.progress >= 0
        onWheel: (event) => {
            if (event.angleDelta.y === 0) return
            var step = event.angleDelta.y > 0 ? 0.01 : -0.01
            root.progressEdited(Math.max(0, Math.min(1, root.progress + step)))
        }
    }

    // v11 : icône optionnelle façon badge (calque sur le mockup HTML
    // fourni — network-icon) — vide par défaut, donc la carte Audio
    // (qui n'en a pas dans le mockup) n'est pas concernée.
    property string icon: ""

    ColumnLayout {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 10
        spacing: 4

        Rectangle {
            visible: root.icon.length > 0
            Layout.bottomMargin: 4
            implicitWidth: 26
            implicitHeight: 26
            radius: Theme.radiusSmall
            color: Theme.accentMuted
            border.width: 1
            border.color: Theme.accent

            Icon {
                anchors.centerIn: parent
                name: root.icon
                color: Theme.accent
                implicitWidth: 13
                implicitHeight: 13
            }
        }

        Text {
            Layout.fillWidth: true
            text: root.label
            color: Theme.textMuted
            font.pixelSize: Theme.fontLabel
            font.family: "JetBrains Mono"
            elide: Text.ElideRight
        }

        Text {
            Layout.fillWidth: true
            text: root.value
            color: Theme.textPrimary
            font.pixelSize: root.value.length > 6 ? 18 : 32
            font.family: "JetBrains Mono"
            font.bold: true
            font.letterSpacing: -1
            elide: Text.ElideRight
            Layout.topMargin: 2
            Layout.bottomMargin: 2
        }

        RowLayout {
            visible: root.sub.length > 0
            Layout.fillWidth: true
            spacing: 4

            Text {
                Layout.fillWidth: true
                text: root.sub
                color: subHover.hovered && root.subClickable ? Theme.textSecondary : Theme.textMuted
                font.pixelSize: Theme.fontBody
                font.family: "JetBrains Mono"
                elide: Text.ElideRight

                Behavior on color { ColorAnimation { duration: Theme.durationFast } }
            }

            // v15 : flèche "▾" retirée — devenue redondante depuis que
            // toute la carte est cliquable (`cardClickable`), le hover
            // sur le texte (couleur) suffit comme affordance.
            HoverHandler { id: subHover; enabled: root.subClickable }
            TapHandler { enabled: root.subClickable; onTapped: root.subTapped() }
        }

        Text {
            visible: root.meta.length > 0
            Layout.fillWidth: true
            text: root.meta
            color: Theme.textMuted
            font.pixelSize: Theme.fontLabel
            font.family: "JetBrains Mono"
            elide: Text.ElideRight
        }

        // -- Barre lecture seule (progress bar classique) --------------
        Rectangle {
            visible: root.progress >= 0 && !root.interactive
            Layout.fillWidth: true
            Layout.topMargin: 7
            height: 6
            radius: 3
            color: Theme.surfaceHover

            Rectangle {
                width: parent.width * Math.max(0, Math.min(1, root.progress))
                height: parent.height
                radius: parent.radius
                color: Theme.accent
            }
        }

        // -- Slider draggable --------------------------------------------
        Item {
            id: sliderTrack
            visible: root.progress >= 0 && root.interactive
            Layout.fillWidth: true
            Layout.topMargin: 7
            // Zone plus haute que la barre visible : cible tactile
            // confortable sans agrandir le rendu visuel.
            implicitHeight: 18

            readonly property real clampedProgress: Math.max(0, Math.min(1, root.progress))

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                height: 6
                radius: 1
                color: Theme.surfaceHover

                Rectangle {
                    width: parent.width * sliderTrack.clampedProgress
                    height: parent.height
                    radius: parent.radius
                    color: Theme.accent
                }
            }

            Rectangle {
                width: 14
                height: 14
                radius: 2
                color: Theme.textPrimary
                border.width: 2
                border.color: Theme.accent
                anchors.verticalCenter: parent.verticalCenter
                x: sliderTrack.clampedProgress * (sliderTrack.width - width)
            }

            MouseArea {
                anchors.fill: parent
                onPressed: (mouse) => {
                    var v = Math.max(0, Math.min(1, mouse.x / sliderTrack.width))
                    root.progressEdited(v)
                }
                onPositionChanged: (mouse) => {
                    if (pressed) {
                        var v = Math.max(0, Math.min(1, mouse.x / sliderTrack.width))
                        root.progressEdited(v)
                    }
                }
            }
        }

        Rectangle {
            visible: root.tag.length > 0
            Layout.topMargin: Theme.spacingMD
            implicitWidth: tagLabel.implicitWidth + 16
            implicitHeight: 22
            radius: 2
            color: Theme.accentMuted
            border.width: 1
            border.color: Theme.accent

            Text {
                id: tagLabel
                anchors.centerIn: parent
                text: root.tag
                color: Theme.textPrimary
                font.pixelSize: Theme.fontLabel
                font.family: "JetBrains Mono"
                font.bold: true
            }
        }
    }
}
