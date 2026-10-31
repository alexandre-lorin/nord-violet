pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

PanelWindow {
    id: root
    screen: Quickshell.screens.find(s => s.name === Quickshell.env("NV_SESSION_MONITOR")) ?? Quickshell.screens[0]
    anchors { top: true; bottom: true; left: true; right: true }
    exclusiveZone: -1
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "nord-violet-session"
    color: "#0b0b10"
    property color accent: Quickshell.env("NV_SESSION_ACCENT") || "#9b7cff"
    property var actions: JSON.parse(Quickshell.env("NV_SESSION_ACTIONS") || "[]")
    property bool preview: Quickshell.env("NV_SESSION_PREVIEW") === "1"
    property int selected: 0
    property int pending: -1
    property bool confirmYes: false
    property string error: ""
    property bool busy: false
    property date now: new Date()
    property real layoutScale: Math.min(1.45, Math.max(0.82, (height - 72) / 430))
    property bool narrow: width < 760 * layoutScale
    property int actionHeight: 54
    Timer { interval: 1000; running: true; repeat: true; onTriggered: root.now = new Date() }

    function choose(index: int): void {
        if (root.busy || index < 0 || index >= root.actions.length) return
        root.error = ""
        root.selected = index
        if (root.actions[index].confirm) { root.pending = index; root.confirmYes = false }
        else execute(index)
    }
    function execute(index: int): void {
        if (root.busy) return
        if (root.preview) {
            console.log("PREVIEW_ACTION " + root.actions[index].id)
            root.pending = -1
            root.error = "Aperçu : « " + root.actions[index].title + " » simulé."
            return
        }
        root.busy = true
        actionProcess.command = root.actions[index].command
        actionProcess.running = true
    }
    Process {
        id: actionProcess
        onExited: exitCode => {
            if (exitCode === 0) Qt.quit()
            else {
                root.busy = false
                root.pending = -1
                root.error = "L’action n’a pas abouti (code " + exitCode + ")."
            }
        }
    }
    function handleKey(event): void {
            if (event.isAutoRepeat || root.busy) { event.accepted = true; return }
            if (event.key === Qt.Key_Escape) {
                if (root.pending >= 0) root.pending = -1
                else Qt.quit()
            } else if (root.pending >= 0) {
                if (event.key === Qt.Key_Tab || event.key === Qt.Key_Left || event.key === Qt.Key_Right) root.confirmYes = !root.confirmYes
                else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    if (root.confirmYes) root.execute(root.pending)
                    else root.pending = -1
                }
            } else if (event.key === Qt.Key_Down || (event.key === Qt.Key_Tab && !(event.modifiers & Qt.ShiftModifier))) root.selected = (root.selected + 1) % 5
            else if (event.key === Qt.Key_Up || event.key === Qt.Key_Backtab || (event.key === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier))) root.selected = (root.selected + 4 + (root.selected < 0 ? 1 : 0)) % 5
            else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                root.choose(root.selected < 0 ? 0 : root.selected)
            } else {
                const key = event.text.toUpperCase()
                const index = root.actions.findIndex(action => action.key === key)
                if (index >= 0) root.choose(index)
            }
            event.accepted = true
        }
    // Preview-only automation exercises the same action/confirmation handlers.
    IpcHandler {
        target: "session"
        function status(): string { return JSON.stringify({preview: root.preview, confirmYes: root.confirmYes, pending: root.pending, selected: root.selected, error: root.error, screen: root.screen.name}) }
        function previewKey(code: int, modifiers: int, text: string): void { if (root.preview) root.handleKey({key:code, modifiers:modifiers, text:text, isAutoRepeat:false, accepted:false}) }
        function previewChoose(index: int): void { if (root.preview) root.choose(index) }
        function previewConfirm(): void { if (root.preview && root.pending >= 0) root.execute(root.pending) }
        function previewCancel(): void { if (root.preview) root.pending = -1 }
        function close(): void { Qt.quit() }
    }
    Item {
        id: keyboard
        anchors.fill: parent
        focus: true
        Component.onCompleted: forceActiveFocus()
        Keys.onPressed: event => root.handleKey(event)
        Item {
            id: composition
            anchors.centerIn: parent
            width: Math.min(840, (parent.width - 64) / root.layoutScale)
            scale: root.layoutScale
            height: root.narrow ? 600 : 390
            visible: root.pending < 0

            Rectangle {
                anchors.fill: parent
                radius: 20
                color: "#0e0e15"
                border.width: 1
                border.color: "#24242e"
            }
            Rectangle {
                x: 42; y: 38; width: 42; height: 2; radius: 1
                color: root.accent
            }
            Item {
                id: clockBlock
                x: 42
                y: root.narrow ? 54 : 82
                width: root.narrow ? parent.width - 84 : 270
                height: 210
                Text {
                    id: sessionLabel
                    text: "SESSION"
                    font.family: "Inter"; font.pixelSize: 9; font.weight: Font.DemiBold
                    font.letterSpacing: 2
                    color: root.accent
                }
                Text {
                    id: clockText
                    anchors.top: sessionLabel.bottom; anchors.topMargin: 24
                    text: Qt.formatDateTime(root.now, "HH:mm")
                    font.family: "Inter"; font.pixelSize: root.narrow ? 58 : 68; font.weight: Font.Medium
                    font.letterSpacing: -3
                    color: "#f0eff5"
                }
                Text {
                    anchors.top: clockText.bottom; anchors.topMargin: 14
                    text: Qt.locale("fr_FR").toString(root.now, "dddd d MMMM yyyy")
                    font.family: "Inter"; font.pixelSize: 11
                    color: "#8d8d9a"
                }
                Text {
                    anchors.left: parent.left; anchors.bottom: parent.bottom
                    text: root.preview ? "APERÇU SÉCURISÉ" : "NORD VIOLET"
                    font.family: "JetBrains Mono"; font.pixelSize: 8; font.letterSpacing: 1.4
                    color: "#595966"
                }
            }
            Rectangle {
                visible: !root.narrow
                x: 340; y: 42; width: 1; height: parent.height - 84
                color: "#24242e"
            }
            Column {
                id: actionList
                x: root.narrow ? 42 : 378
                y: root.narrow ? 286 : 38
                width: root.narrow ? parent.width - 84 : parent.width - x - 36
                spacing: 5
                Repeater {
                    model: root.actions
                    delegate: Item {
                        id: entry
                        required property var modelData
                        required property int index
                        width: actionList.width
                        height: root.actionHeight + (entry.index === 2 ? 16 : 0)
                        Rectangle {
                            visible: entry.index === 2
                            height: visible ? 1 : 0
                            width: parent.width
                            y: 7
                            color: "#24242d"
                        }
                        Rectangle {
                            y: entry.index === 2 ? 16 : 0
                            width: parent.width
                            height: root.actionHeight
                            radius: 10
                            color: root.selected === entry.index ? "#181721" : "transparent"
                            border.width: root.selected === entry.index ? 1 : 0
                            border.color: Qt.alpha(root.accent, 0.28)
                            Rectangle {
                                visible: root.selected === entry.index
                                anchors.left: parent.left; anchors.leftMargin: 1
                                anchors.verticalCenter: parent.verticalCenter
                                width: 2; height: 24; radius: 1
                                color: root.accent
                            }
                            Text {
                                anchors.left: parent.left; anchors.leftMargin: 18; anchors.verticalCenter: parent.verticalCenter
                                text: entry.modelData.title
                                font.family: "Inter"; font.pixelSize: 16; font.weight: root.selected === entry.index ? Font.Medium : Font.Normal
                                color: root.selected === entry.index ? "#f2f1f7" : "#aaaab6"
                            }
                            Rectangle {
                                anchors.right: parent.right; anchors.rightMargin: 12; anchors.verticalCenter: parent.verticalCenter
                                width: 32; height: 28; radius: 7
                                color: root.selected === entry.index ? Qt.alpha(root.accent, 0.1) : "#111118"
                                border.width: 1
                                border.color: root.selected === entry.index ? Qt.alpha(root.accent, 0.62) : "#2b2b35"
                                Text {
                                    anchors.centerIn: parent
                                    text: entry.modelData.key
                                    font.family: "JetBrains Mono"; font.pixelSize: 10; font.weight: Font.Medium
                                    color: root.selected === entry.index ? root.accent : "#777784"
                                }
                            }
                            MouseArea {
                                anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onEntered: root.selected = entry.index
                                onClicked: root.choose(entry.index)
                            }
                        }
                    }
                }
            }

        }
        Rectangle {
            anchors.centerIn: parent
            visible: root.pending >= 0
            width: Math.min(360, (parent.width - 48) / root.layoutScale); height: 250
            scale: root.layoutScale
            color: "#121219"; radius: 18; border.color: "#292932"
            Column {
                anchors.fill: parent; anchors.margins: 28; spacing: 18
                Text { text: "VOTRE SESSION"; font.family: "Inter"; font.pixelSize: 10; font.letterSpacing: 1.5; color: "#858591" }
                Text {
                    text: root.pending < 0 ? "" : root.actions[root.pending].title + " ?"
                    font.family: "Inter"; font.pixelSize: 24; color: "#e5e5ec"
                }
                Text {
                    width: parent.width; wrapMode: Text.WordWrap
                    text: "Vos applications seront fermées.\nPensez à enregistrer votre travail."
                    font.family: "Inter"; font.pixelSize: 12; lineHeight: 1.45; color: "#858591"
                }
                Row {
                    anchors.right: parent.right; spacing: 10
                    Repeater {
                        model: ["Annuler", "Confirmer"]
                        delegate: Rectangle {
                            required property string modelData
                            required property int index
                            width: 106; height: 38; radius: 8; color: "transparent"
                            border.color: root.confirmYes === (index === 1) ? root.accent : "#292932"
                            Text { anchors.centerIn: parent; text: parent.modelData; font.family: "Inter"; font.pixelSize: 12; color: "#e5e5ec" }
                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: { if (parent.index === 1) root.execute(root.pending); else root.pending = -1 }
                            }
                        }
                    }
                }
            }
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: parent.bottom; anchors.bottomMargin: 32
            text: root.busy ? "Action en cours…" : root.error
            font.family: "Inter"; font.pixelSize: 12; color: "#bfc0ca"
        }
    }
}
