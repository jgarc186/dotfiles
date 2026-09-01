//
// The pill that slides between workspaces.
//
pragma ComponentBehavior: Bound

import QtQuick
import qs.components
import qs.config
import qs.services

StyledRect {
    id: root

    required property int activeWsId
    required property Repeater workspaces
    required property Item mask
    required property int shown

    readonly property int currentIdx: {
        let i = activeWsId - 1;
        while (i < 0)
            i += shown;
        return i % shown;
    }

    readonly property Item current: workspaces.count > 0 ? workspaces.itemAt(currentIdx) : null

    y: (current?.y ?? 0) + mask.y
    implicitWidth: Appearance.sizes.bar.innerWidth - Appearance.padding.small
    implicitHeight: current?.height ?? 0

    radius: Appearance.rounding.full
    color: Colours.palette.m3primary

    Behavior on y {
        Anim {
            type: Anim.Emphasized
        }
    }

    Behavior on implicitHeight {
        Anim {
            type: Anim.Emphasized
        }
    }
}
