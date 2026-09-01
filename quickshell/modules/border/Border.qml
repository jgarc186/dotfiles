//
// The frame the whole shell sits in.
//
// Caelestia draws this with an SDF plugin so drawers can melt into it. Without
// that, one ShapePath with two subpaths and an odd-even fill rule gives the same
// result for the static case: a screen-filling fill with a rounded rectangular
// hole punched out of it.
//
import QtQuick
import QtQuick.Shapes
import qs.components
import qs.config
import qs.services

Shape {
    id: root

    // Left is wider than the rest - that's where the bar lives
    property real borderLeft: Config.border.thickness
    property real borderRight: Config.border.thickness
    property real borderTop: Config.border.thickness
    property real borderBottom: Config.border.thickness
    property real rounding: Config.border.rounding
    property color color: Colours.tPalette.m3surface

    preferredRendererType: Shape.CurveRenderer
    antialiasing: true

    ShapePath {
        fillColor: root.color
        fillRule: ShapePath.OddEvenFill
        strokeWidth: 0
        strokeColor: "transparent"

        // Outer: the full screen
        PathRectangle {
            width: root.width
            height: root.height
            radius: 0
        }

        // Inner: the hole the desktop shows through
        PathRectangle {
            x: root.borderLeft
            y: root.borderTop
            width: Math.max(0, root.width - root.borderLeft - root.borderRight)
            height: Math.max(0, root.height - root.borderTop - root.borderBottom)
            radius: root.rounding
        }

        Behavior on fillColor {
            CAnim {}
        }
    }

    // No Behavior on borderLeft: it tracks the bar's width, which animates itself

    Behavior on borderTop {
        Anim {}
    }

    Behavior on borderRight {
        Anim {}
    }

    Behavior on borderBottom {
        Anim {}
    }
}
