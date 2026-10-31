pragma Singleton
import QtQuick
import Quickshell.Io

// Item plutôt que QtObject : QtObject seul n'a pas de "default property"
// pour accueillir des enfants déclarés inline (les Process ci-dessous),
// il aurait fallu passer par des property wrappers explicites. Item
// n'est jamais affiché (singleton, jamais parenté dans une scène), donc
// aucun effet de bord à utiliser Item ici juste pour ce confort.
Item {
    id: root

    // -- Accent : seul canal swappable en live pour l'instant --------
    // Décision : swap réel (pas un stub), mais un seul canal de couleur
    // plutôt qu'un moteur de palette complet (bg/surface/text restent
    // fixes). Tous les composants qui référencent déjà Root.Colors.accent
    // se mettent à jour automatiquement (binding QML classique) —
    // rien à faire ailleurs dans le code pour que le swap soit "live".
    property color accent: "#9b7cff"

    readonly property color bg: "#020204"
    readonly property color surface: "#3b4252"
    readonly property color surfaceLight: "#0a0a10"
    readonly property color secondary: "#8995a6"
    readonly property color text: "#e5deeb"
    readonly property color danger: "#bf616a"
    readonly property int radius: 10

    // Les 4 pastilles du mockup — réutilisent les tokens existants
    // plutôt que d'inventer une nouvelle palette de zéro.
    readonly property var accentPresets: [
        { name: "Violet", value: "#9b7cff" },
        { name: "Gris", value: "#8995a6" },
        { name: "Ardoise", value: "#3b4252" },
        { name: "Sombre", value: "#020204" }
    ]

    // CORRECTIF (voir handoff §4.6) : Qt.resolvedUrl() ne résout PAS vers
    // un file:// réel ici — Quickshell charge apparemment les pages via
    // un espace de noms virtuel interne (observé : les commandes
    // résolvaient vers "qrc:/qs-blackhole" et échouaient au runtime).
    // L'hypothèse "dossiers XDG frères" est donc invalidée, pas juste
    // non confirmée. Chemin absolu en dur, cohérent avec le reste
    // (single-machine, single-user, username confirmé "toubi").
    readonly property string _scriptPath: "/home/toubi/.config/quickshell/nord-violet-cc/scripts/accentctl.sh"
    readonly property string _statePath: "/home/toubi/.config/quickshell/nord-violet-cc/state/accent"

    // Appelé par AppearancePage. Effet immédiat dans tout le QML
    // (binding réactif), puis persistance + propagation au bureau en
    // arrière-plan via le script (argv only, jamais de shell concaténé,
    // même convention que wbctl.sh).
    function setAccent(hex) {
        root.accent = hex
        accentWriteProc.command = [root._scriptPath, hex]
        accentWriteProc.running = true
    }

    Process { id: accentWriteProc }

    // Lecture de l'état persisté au démarrage, pour retrouver le dernier
    // accent choisi au lancement suivant de qs.
    //
    // NOTE TECHNIQUE : Process.stdout + StdioCollector est l'API
    // Quickshell.Io telle que documentée au moment où j'écris ceci. Si
    // ta version de Quickshell l'expose différemment, `qs -c
    // nord-violet-cc` te le dira au démarrage (erreur QML pointant sur
    // ce bloc précis) — et ça n'affecte QUE la persistance de l'accent :
    // si tu commentes ce Process, le reste du panneau (y compris le
    // swap live lui-même) continue de fonctionner, l'accent revient
    // juste au violet par défaut à chaque relance.
    Process {
        id: accentReadProc
        command: ["cat", root._statePath]
        stdout: StdioCollector {
            onStreamFinished: {
                var v = text.trim()
                if (/^#[0-9a-fA-F]{6}$/.test(v)) root.accent = v
            }
        }
    }

    Component.onCompleted: accentReadProc.running = true
}
