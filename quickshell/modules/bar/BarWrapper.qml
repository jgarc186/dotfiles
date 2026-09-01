//
// Sizes and hides the bar.
//
// Collapses to the plain border thickness when a window goes fullscreen, so the
// frame stays even all the way round instead of leaving a fat left edge.
//
import QtQuick
import Quickshell
import qs.components
import qs.config

Item {
    id: root

    required property ShellScreen screen
    required property bool fullscreen
    required property int contentWidth

    clip: true
    implicitWidth: fullscreen ? Config.border.thickness : contentWidth

    Bar {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: root.contentWidth

        screen: root.screen
    }

    Behavior on implicitWidth {
        Anim {
            type: Anim.Emphasized
        }
    }
}
