import QtQuick
import "../theme"

// v19 — set d'icônes réel, remplace les glyphes Unicode (♪ ● ⊘ ◆ ♢ ›)
// utilisés jusqu'ici partout dans le projet (voir HANDOFF v17.x /
// discussion icônes). Un seul jeu, un seul trait, cohérent, au lieu de
// symboles réutilisés pour 2 sens différents (◆ servait à la fois pour
// Bluetooth ET réseau verrouillé).
//
// PREMIÈRE UTILISATION DE Canvas DANS CE PROJET — jamais testé en
// rendu réel. Canvas est un élément QtQuick core (pas de module en
// plus à importer), donc pas de risque de dépendance manquante, mais
// le dessin lui-même (coordonnées, arcs) n'a été vérifié que
// visuellement dans les aperçus HTML de cette session, jamais en QML.
// Si une icône ne s'affiche pas du tout : vérifier d'abord que
// `name` matche exactement une des chaînes ci-dessous (aucun warning
// silencieux sinon, l'icône sera juste vide).
//
// Usage : Icon { name: "wifi"; width: 16; height: 16; color: Theme.accent }
Item {
    id: root
    property string name: ""
    property color color: Theme.accent
    implicitWidth: 20
    implicitHeight: 20

    Canvas {
        id: cv
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            if (width <= 0 || height <= 0) return

            var s = width / 24
            ctx.scale(s, s)
            ctx.strokeStyle = root.color
            ctx.fillStyle = root.color
            ctx.lineCap = "round"
            ctx.lineJoin = "round"

            if (root.name === "dnd") {
                // Ne pas déranger — anneau + minus, sans le "sceau" à
                // dents (retiré sur demande explicite, v19).
                ctx.lineWidth = 1.4 / s
                ctx.beginPath()
                ctx.arc(12, 12, 7.2, 0, Math.PI * 2)
                ctx.stroke()
                ctx.beginPath()
                ctx.moveTo(8.8, 12)
                ctx.lineTo(15.2, 12)
                ctx.stroke()

            } else if (root.name === "chevron") {
                // Réglages — chevron, V2 validée (trait bold 2.4).
                ctx.lineWidth = 2.4 / s
                ctx.beginPath()
                ctx.moveTo(9, 4)
                ctx.lineTo(17, 12)
                ctx.lineTo(9, 20)
                ctx.stroke()

            } else if (root.name === "wifi") {
                // v24 : éventail élargi (108° -> 126° d'ouverture) + point
                // légèrement plus gros — la version précédente était trop
                // pincée/étroite pour se lire clairement en petit (14px
                // dans le badge du header). Toujours pas testé en live.
                ctx.lineWidth = 1.6 / s
                ctx.beginPath()
                ctx.arc(12, 17, 1.3, 0, Math.PI * 2)
                ctx.fill()
                ctx.beginPath()
                ctx.arc(12, 17, 5, Math.PI * 1.15, Math.PI * 1.85)
                ctx.stroke()
                ctx.beginPath()
                ctx.arc(12, 17, 9.5, Math.PI * 1.15, Math.PI * 1.85)
                ctx.stroke()

            } else if (root.name === "bluetooth") {
                // Rune bluetooth classique (forme générique/fonctionnelle,
                // pas le logo de marque) — zigzag simple.
                ctx.lineWidth = 1.5 / s
                ctx.beginPath()
                ctx.moveTo(8, 7)
                ctx.lineTo(16, 13)
                ctx.lineTo(12, 16)
                ctx.lineTo(12, 4)
                ctx.lineTo(16, 7)
                ctx.lineTo(8, 13)
                ctx.stroke()

            } else if (root.name === "bell") {
                ctx.lineWidth = 1.5 / s
                ctx.beginPath()
                ctx.arc(12, 10, 5, Math.PI, 0, false)
                ctx.lineTo(18, 16)
                ctx.lineTo(6, 16)
                ctx.closePath()
                ctx.stroke()
                ctx.beginPath()
                ctx.arc(12, 18, 1.6, 0, Math.PI)
                ctx.stroke()

            } else if (root.name === "lock") {
                ctx.lineWidth = 1.5 / s
                ctx.strokeRect(6.5, 11, 11, 8)
                ctx.beginPath()
                ctx.arc(12, 11, 4, Math.PI, 0, false)
                ctx.stroke()

            } else if (root.name === "brightness") {
                // v30 — soleil : disque plein + 8 rayons courts,
                // symétrique. Utilisée par Osd.qml (luminosité).
                ctx.lineWidth = 1.6 / s
                ctx.beginPath()
                ctx.arc(12, 12, 3.6, 0, Math.PI * 2)
                ctx.fill()
                var rays = 8
                var r1 = 6.2, r2 = 9.2
                for (var i = 0; i < rays; i++) {
                    var a = (Math.PI * 2 / rays) * i
                    ctx.beginPath()
                    ctx.moveTo(12 + Math.cos(a) * r1, 12 + Math.sin(a) * r1)
                    ctx.lineTo(12 + Math.cos(a) * r2, 12 + Math.sin(a) * r2)
                    ctx.stroke()
                }
            } else if (root.name === "profile") {
                ctx.lineWidth = 1.5 / s
                ctx.beginPath()
                ctx.arc(12, 8, 3.2, 0, Math.PI * 2)
                ctx.stroke()
                ctx.beginPath()
                ctx.arc(12, 18, 6, Math.PI, 0)
                ctx.stroke()
            } else if (root.name === "focus") {
                ctx.lineWidth = 1.5 / s
                ctx.beginPath()
                ctx.arc(12, 12, 7.5, 0, Math.PI * 2)
                ctx.stroke()
                ctx.beginPath()
                ctx.arc(12, 12, 2.2, 0, Math.PI * 2)
                ctx.fill()
                ctx.beginPath()
                ctx.moveTo(12, 2.5); ctx.lineTo(12, 5)
                ctx.moveTo(12, 19); ctx.lineTo(12, 21.5)
                ctx.moveTo(2.5, 12); ctx.lineTo(5, 12)
                ctx.moveTo(19, 12); ctx.lineTo(21.5, 12)
                ctx.stroke()
            }
        }

        Component.onCompleted: requestPaint()
    }

    onColorChanged: cv.requestPaint()
    onNameChanged: cv.requestPaint()
    onWidthChanged: cv.requestPaint()
    onHeightChanged: cv.requestPaint()
}
