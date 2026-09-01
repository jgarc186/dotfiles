//
// A Material Symbols glyph in a fixed square box.
//
// Material Symbols is a variable font: FILL morphs an outlined glyph into a
// filled one and GRAD thickens strokes for dark backgrounds. Animating `fill`
// is what gives icon state changes their weight.
//
// The box is size * 4/3 px - the glyph's real 20/24/32dp footprint - which keeps
// every icon aligned on the same grid, and keeps the layout intact if the font
// isn't installed and glyph *names* render as words instead.
//
import QtQuick
import qs.config
import qs.services

Item {
    id: root

    property string text
    property color color: Colours.palette.m3onSurface
    property real fill: 0
    property int grade: Colours.light ? 0 : -25
    property int size: Appearance.font.size.iconSmall
    property int weight: Font.Normal
    property bool animate: false

    implicitWidth: Math.round(size * 4 / 3)
    implicitHeight: implicitWidth
    clip: true

    StyledText {
        anchors.centerIn: parent

        animate: root.animate
        text: root.text
        color: root.color

        // Distance-field rendering honours variable axes; native rendering
        // silently ignores them on some drivers.
        renderType: Text.QtRendering

        font.family: Appearance.font.family.material
        font.pointSize: root.size
        font.variableAxes: ({
                FILL: root.fill.toFixed(2),
                GRAD: root.grade,
                wght: root.weight,
                opsz: 24
            })
    }

    Behavior on fill {
        Anim {
            type: Anim.DefaultEffects
        }
    }
}
