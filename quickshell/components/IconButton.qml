//
// A round Material Symbols button with the M3 state layer.
//
import QtQuick
import qs.config
import qs.services

Item {
    id: root

    required property string icon
    property color colour: Colours.palette.m3onSurfaceVariant
    property real fill: 0
    property int size: Appearance.font.size.iconSmall

    signal clicked

    implicitWidth: glyph.implicitWidth + Appearance.padding.small
    implicitHeight: implicitWidth

    StateLayer {
        radius: Appearance.rounding.full
        color: root.colour
        disabled: !root.enabled

        onClicked: root.clicked()
    }

    MaterialIcon {
        id: glyph

        anchors.centerIn: parent

        animate: true
        text: root.icon
        color: root.colour
        fill: root.fill
        size: root.size
        opacity: root.enabled ? 1 : 0.5
    }
}
