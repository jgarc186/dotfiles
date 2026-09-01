//
// Material 3 plain tooltip: a small inverse-surface bubble.
//
// Hosted by ShellWindow rather than by the widget it describes, because the bar
// clips its contents - anything drawn beside an icon would be cut off.
//
import QtQuick
import qs.config
import qs.services

StyledRect {
    property alias text: label.text

    implicitWidth: label.implicitWidth + Appearance.padding.small * 2
    implicitHeight: label.implicitHeight + Appearance.padding.extraSmall * 2

    color: Colours.palette.m3inverseSurface
    radius: Appearance.rounding.extraSmall

    StyledText {
        id: label

        anchors.centerIn: parent

        color: Colours.palette.m3inverseOnSurface
        font.pointSize: Appearance.font.size.small
    }
}
