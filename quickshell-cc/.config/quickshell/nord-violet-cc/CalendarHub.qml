import Quickshell
import Quickshell.Io

Scope {
    id: calendarHub
    property string activeScreen: ""
    property var bars: []
    property var common: ({})
    function parseConfig(file) {
        return JSON.parse(file.text().replace(/^\s*\/\/.*$/gm, ""))
    }
    function barFor(name) {
        const entry = bars.find(bar => bar.output === name)
        return entry ? Object.assign({}, common, entry) : null
    }
    FileView {
        id: barConfig
        path: Quickshell.env("HOME") + "/.config/waybar/config.jsonc"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try { calendarHub.bars = calendarHub.parseConfig(barConfig) }
            catch (error) { console.warn("Calendar: invalid Waybar config", error) }
        }
    }
    FileView {
        id: commonConfig
        path: Quickshell.env("HOME") + "/.config/waybar/modules-common.jsonc"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try { calendarHub.common = calendarHub.parseConfig(commonConfig) }
            catch (error) { console.warn("Calendar: invalid Waybar modules", error) }
        }
    }
    Variants {
        model: Quickshell.screens
        CalendarClock { hub: calendarHub }
    }
    Variants {
        model: Quickshell.screens
        WorkspaceRibbon { hub: calendarHub }
    }
    IpcHandler {
        target: "calendar"
        function close(): void { calendarHub.activeScreen = "" }
        function toggle(screenName: string): void {
            for (const screen of Quickshell.screens) {
                if (screen.name === screenName) {
                    calendarHub.activeScreen = calendarHub.activeScreen === screenName ? "" : screenName
                    return
                }
            }
        }
    }
}
