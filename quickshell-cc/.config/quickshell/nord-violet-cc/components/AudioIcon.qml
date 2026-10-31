import QtQuick
import "../theme"

// v19 — icône audio dynamique (V3 validée : cône plein, trait bold,
// 2 arcs max). `pct` piloté par le volume réel (root.audioPct côté
// appelant) — 0 = croix (muet), puis 1 arc, puis 2 arcs au-dessus du
// seuil. Même avertissement Canvas que Icon.qml (première utilisation
// dans ce projet, jamais testé en rendu réel).
//
// Usage : AudioIcon { pct: root.audioPct; width: 16; height: 16 }
Item {
    id: root
    property real pct: 0
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
            ctx.fillStyle = root.color
            ctx.strokeStyle = root.color
            ctx.lineCap = "round"
            ctx.lineWidth = 2.2 / s

            // Cône du speaker — identique quel que soit l'état.
            ctx.beginPath()
            ctx.moveTo(3, 9)
            ctx.lineTo(6, 9)
            ctx.lineTo(10, 5)
            ctx.lineTo(10, 19)
            ctx.lineTo(6, 15)
            ctx.lineTo(3, 15)
            ctx.closePath()
            ctx.fill()

            if (root.pct <= 0) {
                ctx.beginPath()
                ctx.moveTo(14, 9)
                ctx.lineTo(18.5, 13.5)
                ctx.moveTo(18.5, 9)
                ctx.lineTo(14, 13.5)
                ctx.stroke()
            } else {
                ctx.beginPath()
                ctx.arc(12, 12, 3, -0.70, 0.70)
                ctx.stroke()
                if (root.pct > 55) {
                    ctx.beginPath()
                    ctx.arc(12, 12, 5.3, -0.70, 0.70)
                    ctx.stroke()
                }
            }
        }

        Component.onCompleted: requestPaint()
    }

    onPctChanged: cv.requestPaint()
    onColorChanged: cv.requestPaint()
    onWidthChanged: cv.requestPaint()
    onHeightChanged: cv.requestPaint()
}
