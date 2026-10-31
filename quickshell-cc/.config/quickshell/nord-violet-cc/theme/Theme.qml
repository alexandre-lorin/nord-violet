pragma Singleton
import QtQuick
import ".." as Root

// Système de design V2 — palette volontairement courte. Le violet
// n'apparaît QUE sur : sélection, état actif, slider, focus. Tout le
// reste passe par surface/texte/bordure en niveaux de gris.
//
// TOUT le futur code (thème, composants, pages) doit lire ses couleurs
// et dimensions ICI, jamais en dur (color: "#..." dans une page = à
// éviter). C'est ce qui permet de changer l'interface entière en un
// seul fichier plus tard.
QtObject {
    id: theme

    // -- Couleurs -----------------------------------------------------
    readonly property color background:    "#0b0b10"
    readonly property color surface:       "#121219"
    readonly property color surfaceHover:  "#181821"
    readonly property color border:        "#24242d"

    readonly property color textPrimary:   "#f4f4f6"
    readonly property color textSecondary: "#b8b8c2"
    readonly property color textMuted:     "#8d8d98"

    // v7 : accent n'est plus une valeur figée. Il reflète en direct
    // Colors.accent (le swap live piloté depuis Apparence — 4 presets,
    // persisté sur disque, propagé à waybar via accentctl.sh). Avant ce
    // changement, seule KeybindsPage (encore sur Root.Colors) réagissait
    // au swap ; tout le reste (Overview, tiles, sidebar, Hyprland...)
    // restait figé sur l'ancien violet en dur. Maintenant tout le
    // panneau réagit au même swap, Colors.qml reste l'unique source de
    // vérité pour la valeur elle-même (édition + persistance).
    readonly property color accent: Root.Colors.accent
    // Version très basse opacité de l'accent, pour les fonds d'état
    // "actif" (jamais l'accent plein en fond — seulement en trait/texte/point).
    readonly property color accentMuted: Qt.rgba(theme.accent.r, theme.accent.g, theme.accent.b, 0.14)

    readonly property color success: "#79d6a3"
    readonly property color warning: "#e2a94f"
    readonly property color danger:  "#e2666f"

    // -- Rayons ---------------------------------------------------------
    readonly property int radiusSmall:  Preferences.corners === "sharp" ? 5 : (Preferences.corners === "soft" ? 12 : 8)
    readonly property int radiusMedium: Preferences.corners === "sharp" ? 8 : (Preferences.corners === "soft" ? 18 : 12)
    readonly property int radiusLarge:  Preferences.corners === "sharp" ? 12 : (Preferences.corners === "soft" ? 24 : 18)

    // -- Espacements (échelle, pas de valeurs magiques ailleurs) --------
    readonly property real densityFactor: Preferences.density === "compact" ? 0.82 : (Preferences.density === "airy" ? 1.18 : 1.0)
    readonly property int spacingXS: Math.round(6 * densityFactor)
    readonly property int spacingSM: Math.round(10 * densityFactor)
    readonly property int spacingMD: Math.round(16 * densityFactor)
    readonly property int spacingLG: Math.round(24 * densityFactor)
    readonly property int spacingXL: Math.round(36 * densityFactor)

    // -- Typographie (4 niveaux de hiérarchie, pas plus) ----------------
    readonly property int fontDisplay: 40  // Niveau 1 : la donnée qui compte ("72%")
    readonly property int fontTitle:   20  // Titre de page
    readonly property int fontBody:    13  // Niveau 2/3 : labels, contenu courant
    readonly property int fontLabel:   11  // Niveau 4 : métadonnées, en-têtes de section

    // -- Durées d'animation (courtes, pas de bounce — cf. retour ChatGPT) --
    readonly property int durationFast: Preferences.motion === "off" ? 0 : (Preferences.motion === "reduced" ? 70 : 120)
    readonly property int durationMedium: Preferences.motion === "off" ? 0 : (Preferences.motion === "reduced" ? 110 : 180)
}
