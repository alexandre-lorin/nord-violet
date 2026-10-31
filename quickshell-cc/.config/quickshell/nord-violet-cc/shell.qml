import Quickshell
import Quickshell.Io

ShellRoot {
    CalendarHub {} // Calendar input surfaces and animated workspace ribbons.
    ControlCenter { id: cc }
    Calculator { id: calculator }
    IpcHandler {
        target: "calculator" // Fenêtre native et moteur scientifique, 8 octobre.
        function open(): void { calculator.open() }
        function close(): void { calculator.hide() }
        function toggle(): void { if (calculator.visible) calculator.hide(); else calculator.open() }
        function status(): string { return JSON.stringify({visible:calculator.visible, scientific:calculator.scientific, error:calculator.error, result:calculator.result}) }
        function evaluate(source: string): string {
            calculator.evaluateExpression(source)
            return JSON.stringify({error:calculator.error, result:calculator.result, message:calculator.status})
        }
        function preview(source: string): string {
            try { return JSON.stringify({value:calculator.preview(source)}) }
            catch(e) { return JSON.stringify({error:String(e.message || e)}) }
        }
    }

    SettingsWindowV2 {
        id: settings
        onBackRequested: {
            visible = false
            cc.openPanel()
        }
    }

    // v18 — flyouts autonomes (audio/wifi), séparés du CC. Voir
    // AudioFlyout.qml/WifiFlyout.qml pour le pourquoi.
    AudioFlyout { id: audioFlyout }
    WifiFlyout { id: wifiFlyout }

    // v30 — OSD volume/luminosité, éphémère (voir Osd.qml).
    Osd { id: osd }

    // Bouton waybar / raccourci existant : inchangé, bascule toujours
    // le popup Control Center.
    // v36 — `cc.visible` direct remplacé par `openPanel()`/
    // `closePanel()`/`togglePanel()` (voir ControlCenter.qml, migration
    // special-workspace) : `visible` ne doit plus être touché après le
    // tout premier open, sous peine de redémapper la fenêtre et de
    // retomber dans le bug "pop centré" que cette migration corrige.
    IpcHandler {
        target: "cc"

        function toggle(): void {
            cc.togglePanel()
        }

        function open(): void {
            cc.openPanel()
        }

        function close(): void {
            cc.closePanel()
        }

        // v16 — accès direct depuis waybar, sans passer par la carte du
        // panneau : clic molette sur le son -> `cc audio`, clic sur le
        // réseau -> `cc wifi`. Ouvre le popup ET le volet correspondant
        // en un seul appel IPC (`panel.openAudioPicker()`/
        // `openWifiPicker()` dans ControlCenter.qml délèguent à
        // `overviewPageItem`). L'accès existant (taper la carte dans le
        // CC déjà ouvert) reste inchangé, ceci s'ajoute.
        function audio(): void {
            cc.openPanel()
            cc.openAudioPicker()
        }

        function wifi(): void {
            cc.openPanel()
            cc.openWifiPicker()
        }

        // v17.1 — debug : `qs -c nord-violet-cc ipc call cc reposition`
        // pendant que le panneau est déjà ouvert, pour tester le
        // repositionnement bas-droite sans dépendre du timing
        // d'ouverture (voir ControlCenter.qml, forceReposition()).
        function reposition(): void {
            cc.forceReposition()
        }
    }

    // v9 — nouveau : Réglages comme app indépendante, ouvrable sans
    // passer par le popup (ex. un 2e bouton waybar ou un bind dédié) :
    //   qs -c nord-violet-cc ipc call settings toggle|open|close
    IpcHandler {
        target: "settings"

        function toggle(): void {
            if (settings.visible) settings.hide()
            else { settings.showNormal(); settings.requestActivate() }
        }

        function open(): void {
            if (!settings.visible) settings.showNormal()
            settings.requestActivate()
        }

        function close(): void {
            settings.visible = false
        }

        function page(name: string): void {
            cc.closePanel()
            if (!settings.visible) settings.showNormal()
            settings.navigate(name)
            settings.requestActivate()
        }

        function status(): string {
            return JSON.stringify({visible: settings.visible, page: settings.currentKey, width: settings.width, height: settings.height})
        }

    }

    // v18 — déclenché par ~/.config/waybar/flyout-trigger.sh (capture
    // hyprctl cursorpos au clic, transmet x/y ici). Args en string
    // (l'IPC transmet du texte) — parseInt/parseFloat côté flyout.
    IpcHandler {
        target: "flyout"

        function audio(x: string, y: string): void {
            audioFlyout.show(parseFloat(x), parseFloat(y))
        }

        function wifi(x: string, y: string): void {
            wifiFlyout.show(parseFloat(x), parseFloat(y))
        }
    }

    // v30 — déclenché par ~/.config/hypr/scripts/osd-trigger.sh, lui-même
    // appelé par les binds XF86 volume/luminosité (hypr/keybinds.conf).
    IpcHandler {
        target: "osd"

        function volume(pct: string, muted: string): void {
            osd.show("volume", parseFloat(pct), muted === "1")
        }

        function brightness(pct: string): void {
            osd.show("brightness", parseFloat(pct), false)
        }
    }
}
