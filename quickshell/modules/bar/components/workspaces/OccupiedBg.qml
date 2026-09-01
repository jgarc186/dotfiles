//
// A raised pill behind each run of consecutive occupied workspaces.
//
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.components
import qs.config
import qs.services

Item {
    id: root

    required property Repeater workspaces
    required property var occupied
    required property int groupOffset
    required property int shown

    // Contiguous runs of occupied workspaces within the visible group
    readonly property var groups: {
        const groups = [];
        let start = -1;

        for (let i = 0; i < shown; i++) {
            const isOccupied = occupied[groupOffset + i + 1] ?? false;
            if (isOccupied && start === -1)
                start = i;
            else if (!isOccupied && start !== -1) {
                groups.push({
                    start: start,
                    end: i - 1
                });
                start = -1;
            }
        }
        if (start !== -1)
            groups.push({
                start: start,
                end: shown - 1
            });

        return groups;
    }

    Repeater {
        model: ScriptModel {
            values: root.groups
        }

        StyledRect {
            id: pill

            required property var modelData

            readonly property Item first: root.workspaces.count > 0 ? root.workspaces.itemAt(modelData.start) : null
            readonly property Item last: root.workspaces.count > 0 ? root.workspaces.itemAt(modelData.end) : null

            anchors.horizontalCenter: root.horizontalCenter

            y: (first?.y ?? 0) - 1
            implicitWidth: Appearance.sizes.bar.innerWidth - Appearance.padding.small + 2
            implicitHeight: first && last ? last.y + last.height - first.y + 2 : 0

            color: Colours.layer(Colours.palette.m3surfaceContainerHigh, 2)
            radius: Appearance.rounding.full

            scale: 0
            Component.onCompleted: scale = 1

            Behavior on scale {
                Anim {
                    easing.bezierCurve: Appearance.anim.curves.standardDecel
                }
            }

            Behavior on y {
                Anim {}
            }

            Behavior on implicitHeight {
                Anim {}
            }
        }
    }
}
