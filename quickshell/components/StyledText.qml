import QtQuick
import qs.config
import qs.services

Text {
    id: root

    // Cross-fade rather than snap when the text itself changes - used by the
    // status icons so a volume icon swap doesn't pop.
    property bool animate: false

    renderType: Text.NativeRendering
    textFormat: Text.PlainText
    color: Colours.palette.m3onSurface

    font.family: Appearance.font.family.sans
    font.pointSize: Appearance.font.size.normal

    Behavior on color {
        CAnim {}
    }

    Behavior on text {
        enabled: root.animate

        SequentialAnimation {
            Anim {
                target: root
                property: "opacity"
                to: 0
                type: Anim.FastEffects
            }
            PropertyAction {}
            Anim {
                target: root
                property: "opacity"
                to: 1
                type: Anim.DefaultEffects
            }
        }
    }
}
