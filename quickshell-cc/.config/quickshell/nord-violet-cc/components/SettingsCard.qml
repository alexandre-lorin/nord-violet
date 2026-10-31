import QtQuick
import QtQuick.Layouts
import "../theme"

// v32 — bloc arrondi qui regroupe plusieurs rows (ToggleRow/SliderRow/
// SelectRow/RowButton), un seul Rectangle au lieu d'une bordure par
// row. Inspiré du look "carte de réglages groupée" de Caelestia
// (modules/nexus/common/ConnectedRect.qml + PageBase.qml), simplifié :
// pas de coins indépendants par row, juste un séparateur fin entre
// chaque enfant géré PAR LES ROWS ELLES-MÊMES (`showDivider`, voir
// ToggleRow/SliderRow/SelectRow/RowButton) — mets `showDivider: false`
// sur la dernière row de chaque carte.
ColumnLayout {
    id: root

    default property alias content: inner.children

    Layout.fillWidth: true
    spacing: 0

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: inner.implicitHeight
        radius: 2
        color: "#0e1015"
        border.width: 1
        border.color: Theme.border
        clip: true

        ColumnLayout {
            id: inner
            width: parent.width
            spacing: 0
        }
    }
}
