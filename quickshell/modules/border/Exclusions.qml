//
// Reserves the border's thickness on each screen edge.
//
// The shell window itself ignores exclusion zones (it has to span the whole
// screen to draw the frame), so four zero-size windows claim the space instead.
// Tiled windows then land exactly inside the frame.
//
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.components
import qs.config

Scope {
    id: root

    required property ShellScreen screen
    required property int barWidth

    ExclusionZone {
        anchors.left: true
        exclusiveZone: root.barWidth
    }

    ExclusionZone {
        anchors.top: true
    }

    ExclusionZone {
        anchors.right: true
    }

    ExclusionZone {
        anchors.bottom: true
    }

    component ExclusionZone: StyledWindow {
        screen: root.screen
        name: "border-exclusion"
        exclusiveZone: Config.border.thickness
        mask: Region {}
        implicitWidth: 1
        implicitHeight: 1
    }
}
