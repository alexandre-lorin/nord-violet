import QtQuick
import "theme"
import "CalendarMath.js" as Dates

Rectangle {
    id: root
    property date today: new Date()
    property date selected: today
    property date month: Dates.monthStart(today, 0)
    readonly property var locale: Qt.locale("fr_FR")
    signal closeRequested()
    implicitWidth: 332
    implicitHeight: 372
    color: Theme.surface
    radius: Theme.radiusLarge
    border.color: Theme.border
    focus: true

    function reset() {
        today = new Date()
        selected = today
        month = Dates.monthStart(today, 0)
    }
    function select(date) {
        selected = date
        month = Dates.monthStart(date, 0)
    }
    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) closeRequested()
        else if (event.key === Qt.Key_Left) select(Dates.moveDay(selected, -1))
        else if (event.key === Qt.Key_Right) select(Dates.moveDay(selected, 1))
        else if (event.key === Qt.Key_Up) select(Dates.moveDay(selected, -7))
        else if (event.key === Qt.Key_Down) select(Dates.moveDay(selected, 7))
        else if (event.key === Qt.Key_PageUp) month = Dates.monthStart(month, -1)
        else if (event.key === Qt.Key_PageDown) month = Dates.monthStart(month, 1)
        else if (event.key === Qt.Key_Home) reset()
        else return
        event.accepted = true
    }
    Text {
        x: 20; y: 23
        text: {
            const value = root.month.toLocaleDateString(root.locale, "MMMM yyyy")
            return value.charAt(0).toUpperCase() + value.slice(1)
        }
        color: Theme.textPrimary
        font.family: "Inter"
        font.pixelSize: 15
        font.weight: Font.DemiBold
    }
    CalendarButton {
        x: 248; y: 17; text: "‹"; description: "Mois précédent"
        onClicked: root.month = Dates.monthStart(root.month, -1)
    }
    CalendarButton {
        x: 284; y: 17; text: "›"; description: "Mois suivant"
        onClicked: root.month = Dates.monthStart(root.month, 1)
    }
    Row {
        x: 20; y: 67; spacing: 4
        Repeater {
            model: ["L", "M", "M", "J", "V", "S", "D"]
            Text {
                required property string modelData
                width: 38; height: 18
                horizontalAlignment: Text.AlignHCenter
                text: modelData
                font.family: "Inter"; font.pixelSize: 10
                color: Theme.textMuted
            }
        }
    }
    Grid {
        x: 20; y: 92; columns: 7; spacing: 4
        Repeater {
            model: Dates.cells(root.month)
            Rectangle {
                id: cell
                required property var modelData
                readonly property bool selected: Dates.sameDay(modelData, root.selected)
                readonly property bool isToday: Dates.sameDay(modelData, root.today)
                width: 38; height: 33; radius: Theme.radiusSmall
                color: selected ? Theme.accentMuted : dayMouse.containsMouse ? Theme.surfaceHover : "transparent"
                border.width: selected ? 1 : 0
                border.color: Theme.accent
                Accessible.role: Accessible.Button
                Accessible.name: modelData.toLocaleDateString(root.locale, "dddd d MMMM yyyy")
                Accessible.onPressAction: root.select(modelData)
                Text {
                    anchors.centerIn: parent
                    text: cell.modelData.getDate()
                    font.family: "Inter"; font.pixelSize: 12
                    color: cell.selected ? Theme.accent : cell.modelData.getMonth() === root.month.getMonth() ? Theme.textPrimary : Theme.textMuted
                    opacity: cell.modelData.getMonth() === root.month.getMonth() ? 1 : 0.5
                }
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: 27; width: 3; height: 3; radius: 2
                    visible: cell.isToday
                    color: Theme.accent
                }
                MouseArea {
                    id: dayMouse
                    anchors.fill: parent; hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { root.select(cell.modelData); root.forceActiveFocus() }
                }
            }
        }
    }
    Rectangle { x: 20; y: 323; width: 292; height: 1; color: Theme.border }
    Text {
        x: 20; y: 339
        text: root.selected.toLocaleDateString(root.locale, "ddd d MMM")
        color: Theme.textMuted
        font.family: "Inter"; font.pixelSize: 11
    }
    CalendarButton {
        x: 218; y: 332; width: 94; text: "Aujourd’hui"
        onClicked: { root.reset(); root.forceActiveFocus() }
    }
}
