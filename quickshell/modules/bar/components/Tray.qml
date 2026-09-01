//
// System tray, as a pill of icons.
//
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import qs.components
import qs.config
import qs.services

StyledRect {
    id: root

    readonly property int padding: Config.bar.tray.background ? Appearance.padding.medium : Appearance.padding.extraSmall

    visible: items.count > 0

    implicitWidth: Appearance.sizes.bar.innerWidth
    implicitHeight: items.count > 0 ? column.implicitHeight + padding * 2 : 0

    color: Config.bar.tray.background ? Colours.tPalette.m3surfaceContainer : "transparent"
    radius: Appearance.rounding.full

    Column {
        id: column

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: Appearance.spacing.small

        add: Transition {
            Anim {
                properties: "scale"
                from: 0
                to: 1
                easing.bezierCurve: Appearance.anim.curves.standardDecel
            }
        }

        move: Transition {
            Anim {
                properties: "scale"
                to: 1
            }
            Anim {
                properties: "x,y"
            }
        }

        Repeater {
            id: items

            model: ScriptModel {
                values: SystemTray.items.values.filter(i => !Config.bar.tray.hiddenIcons.includes(i.id))
            }

            TrayItem {}
        }
    }

    Behavior on implicitHeight {
        Anim {}
    }
}
