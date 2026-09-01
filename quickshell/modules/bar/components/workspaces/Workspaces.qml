pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.config
import qs.services

StyledClippingRect {
    id: root

    required property ShellScreen screen

    readonly property int activeWsId: Hypr.activeWsIdFor(screen)
    readonly property var occupied: Hypr.occupied
    readonly property bool onSpecial: Hypr.specialWsFor(screen) !== ""

    // Workspaces page in groups of `shown`, so ws 6 scrolls the group to 6-10
    readonly property int groupOffset: Math.floor((activeWsId - 1) / Config.bar.workspaces.shown) * Config.bar.workspaces.shown

    implicitWidth: Appearance.sizes.bar.innerWidth
    implicitHeight: layout.implicitHeight + Appearance.padding.small

    color: Colours.tPalette.m3surfaceContainer
    radius: Appearance.rounding.full

    Item {
        anchors.fill: parent

        // Recede while a special workspace is up front
        scale: root.onSpecial ? 0.8 : 1
        opacity: root.onSpecial ? 0.5 : 1

        Loader {
            anchors.fill: parent
            anchors.margins: Appearance.padding.extraSmall

            asynchronous: true
            active: Config.bar.workspaces.occupiedBg

            sourceComponent: OccupiedBg {
                workspaces: workspaces
                occupied: root.occupied
                groupOffset: root.groupOffset
                shown: Config.bar.workspaces.shown
            }
        }

        Loader {
            anchors.horizontalCenter: parent.horizontalCenter

            asynchronous: true
            active: Config.bar.workspaces.activeIndicator

            sourceComponent: ActiveIndicator {
                activeWsId: root.activeWsId
                workspaces: workspaces
                mask: layout
                shown: Config.bar.workspaces.shown
            }
        }

        ColumnLayout {
            id: layout

            anchors.centerIn: parent
            spacing: Appearance.spacing.extraSmall

            Repeater {
                id: workspaces

                model: Config.bar.workspaces.shown

                Workspace {
                    activeWsId: root.activeWsId
                    occupied: root.occupied
                    groupOffset: root.groupOffset
                }
            }
        }

        MouseArea {
            anchors.fill: layout

            onClicked: event => {
                const ws = (layout.childAt(event.x, event.y) as Workspace)?.ws;
                if (!ws)
                    return;
                if (root.activeWsId === ws)
                    Hypr.dispatch("togglespecialworkspace special");
                else
                    Hypr.dispatch(`workspace ${ws}`);
            }
        }

        Behavior on scale {
            Anim {}
        }

        Behavior on opacity {
            Anim {
                type: Anim.DefaultEffects
            }
        }
    }

    // Scroll to change workspace
    WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad

        onWheel: event => {
            if (event.angleDelta.y < 0)
                Hypr.dispatch("workspace r+1");
            else if (root.activeWsId > 1)
                Hypr.dispatch("workspace r-1");
        }
    }
}
