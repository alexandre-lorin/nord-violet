pragma Singleton
import QtQuick
import Quickshell.Io

Item {
    id: root

    property string density: "balanced"
    property string corners: "moderate"
    property string motion: "full"

    readonly property string _statePath: "/home/toubi/.config/quickshell/nord-violet-cc/state/style"
    readonly property string _scriptPath: "/home/toubi/.config/quickshell/nord-violet-cc/scripts/stylectl.sh"

    function setDensity(value) {
        if (["compact", "balanced", "airy"].indexOf(value) < 0) return
        density = value
        persist()
    }

    function setCorners(value) {
        if (["sharp", "moderate", "soft"].indexOf(value) < 0) return
        corners = value
        persist()
    }

    function setMotion(value) {
        if (["off", "reduced", "full"].indexOf(value) < 0) return
        motion = value
        persist()
    }

    function persist() {
        styleWrite.command = [root._scriptPath, density, corners, motion]
        styleWrite.running = true
    }

    Process { id: styleWrite }

    Process {
        id: styleRead
        command: ["cat", root._statePath]
        stdout: StdioCollector {
            onStreamFinished: {
                var parts = text.trim().split(" ")
                if (parts.length !== 3) return
                if (["compact", "balanced", "airy"].indexOf(parts[0]) >= 0) root.density = parts[0]
                if (["sharp", "moderate", "soft"].indexOf(parts[1]) >= 0) root.corners = parts[1]
                if (["off", "reduced", "full"].indexOf(parts[2]) >= 0) root.motion = parts[2]
            }
        }
    }

    Component.onCompleted: styleRead.running = true
}
