//
// Material 3 design tokens.
//
// Values mirror the Material 3 (expressive) spec as used by caelestia-shell, so
// the visual rhythm matches: 4/8/12/16/20/28/32/48 for the geometry scales, the
// M3 motion curves for animation, and Material Symbols Rounded for iconography.
//
// Every scale is derived from a `scale` factor, so the whole shell can be
// resized at once.
//
pragma Singleton

import QtQuick
import Quickshell

Singleton {
    readonly property Rounding rounding: Rounding {}
    readonly property Spacing spacing: Spacing {}
    readonly property Padding padding: Padding {}
    readonly property Fonts font: Fonts {}
    readonly property Anims anim: Anims {}
    readonly property Sizes sizes: Sizes {}
    readonly property Transparency transparency: Transparency {}

    component Rounding: QtObject {
        readonly property real scale: 1
        readonly property int extraSmall: 4 * scale
        readonly property int small: 8 * scale
        readonly property int medium: 12 * scale
        readonly property int large: 16 * scale
        readonly property int largeIncreased: 20 * scale
        readonly property int extraLarge: 28 * scale
        readonly property int extraLargeIncreased: 32 * scale
        readonly property int extraExtraLarge: 48 * scale
        // Rectangle clamps radius to min(w, h) / 2, so anything huge reads as "full"
        readonly property int full: 1000
    }

    component Spacing: QtObject {
        readonly property real scale: 1
        readonly property int extraSmall: 4 * scale
        readonly property int small: 8 * scale
        readonly property int medium: 12 * scale
        readonly property int large: 16 * scale
        readonly property int largeIncreased: 20 * scale
        readonly property int extraLarge: 28 * scale
        readonly property int extraLargeIncreased: 32 * scale
        readonly property int extraExtraLarge: 48 * scale
    }

    component Padding: QtObject {
        readonly property real scale: 1
        readonly property int extraSmall: 4 * scale
        readonly property int small: 8 * scale
        readonly property int medium: 12 * scale
        readonly property int large: 16 * scale
        readonly property int largeIncreased: 20 * scale
        readonly property int extraLarge: 28 * scale
        readonly property int extraLargeIncreased: 32 * scale
        readonly property int extraExtraLarge: 48 * scale
    }

    // Inline components can't nest, so the sub-groups live at document level and
    // are wired together by the wrapper components below.
    component Fonts: QtObject {
        readonly property real scale: 1
        readonly property Families family: Families {}
        readonly property FontSizes size: FontSizes {}
    }

    component Families: QtObject {
        // Degrades gracefully: fontconfig resolves an unknown family to the
        // default sans, so a missing font is ugly rather than fatal.
        // Caelestia uses Google Sans Flex here, which isn't packaged for Arch.
        // Rubik is the font it falls back to elsewhere and is close in spirit.
        readonly property string sans: "Rubik"
        readonly property string mono: "CaskaydiaCove NF"
        readonly property string clock: "Rubik"
        readonly property string workspaces: "Rubik"
        readonly property string material: "Material Symbols Rounded"
    }

    component FontSizes: QtObject {
        readonly property real scale: 1
        readonly property int small: 11 * scale
        readonly property int smaller: 12 * scale
        readonly property int normal: 13 * scale
        readonly property int larger: 15 * scale
        readonly property int large: 18 * scale
        readonly property int extraLarge: 28 * scale
        // Material Symbols are drawn on a 24dp grid; /1.33 converts px to pt
        readonly property int iconSmall: Math.round(20 / 1.33 * scale)
        readonly property int iconMedium: Math.round(24 / 1.33 * scale)
        readonly property int iconLarge: Math.round(32 / 1.33 * scale)
        readonly property int iconExtraLarge: Math.round(48 / 1.33 * scale)
    }

    component Anims: QtObject {
        readonly property Durations durations: Durations {}
        readonly property Curves curves: Curves {}
    }

    component Durations: QtObject {
        readonly property real scale: 1
        readonly property int small: 200 * scale
        readonly property int normal: 400 * scale
        readonly property int large: 600 * scale
        readonly property int extraLarge: 1000 * scale
        readonly property int expressiveFastSpatial: 350 * scale
        readonly property int expressiveDefaultSpatial: 500 * scale
        readonly property int expressiveSlowSpatial: 650 * scale
        readonly property int expressiveFastEffects: 150 * scale
        readonly property int expressiveDefaultEffects: 200 * scale
        readonly property int expressiveSlowEffects: 300 * scale
    }

    // Bezier control points in QEasingCurve BezierSpline form: triplets of
    // points, last must be (1, 1). The spatial curves overshoot past y = 1 on
    // purpose - that springiness is most of the "expressive" feel.
    component Curves: QtObject {
        readonly property list<real> emphasized: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82, 0.25, 1, 1, 1]
        readonly property list<real> emphasizedAccel: [0.3, 0, 0.8, 0.15, 1, 1]
        readonly property list<real> emphasizedDecel: [0.05, 0.7, 0.1, 1, 1, 1]
        readonly property list<real> standard: [0.2, 0, 0, 1, 1, 1]
        readonly property list<real> standardAccel: [0.3, 0, 1, 1, 1, 1]
        readonly property list<real> standardDecel: [0, 0, 0, 1, 1, 1]
        readonly property list<real> expressiveFastSpatial: [0.42, 1.67, 0.21, 0.9, 1, 1]
        readonly property list<real> expressiveDefaultSpatial: [0.38, 1.21, 0.22, 1, 1, 1]
        readonly property list<real> expressiveSlowSpatial: [0.39, 1.29, 0.35, 0.98, 1, 1]
        readonly property list<real> expressiveFastEffects: [0.31, 0.94, 0.34, 1, 1, 1]
        readonly property list<real> expressiveDefaultEffects: [0.34, 0.8, 0.34, 1, 1, 1]
        readonly property list<real> expressiveSlowEffects: [0.34, 0.88, 0.34, 1, 1, 1]
    }

    component Sizes: QtObject {
        readonly property BarSizes bar: BarSizes {}
    }

    component BarSizes: QtObject {
        readonly property int innerWidth: 40
    }

    component Transparency: QtObject {
        readonly property bool enabled: false
        readonly property real base: 0.85
        readonly property real layers: 0.4
    }
}
