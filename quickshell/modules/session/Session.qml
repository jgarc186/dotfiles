//
// Compact session menu, opened from the bar's power button.
//
// The full caelestia session drawer is a screen-wide overlay; this is the same
// idea sized to sit beside the bar, so the power button actually does something.
//
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.config
import qs.services

StyledRect {
    id: root

    readonly property int buttonSize: 52

    implicitWidth: buttonSize + Appearance.padding.large * 2
    implicitHeight: layout.implicitHeight + Appearance.padding.large * 2

    color: Colours.tPalette.m3surfaceContainer
    radius: Appearance.rounding.extraLarge

    ColumnLayout {
        id: layout

        anchors.centerIn: parent
        spacing: Appearance.spacing.small

        SessionButton {
            icon: "lock"
            command: ["hyprlock"]
        }

        SessionButton {
            icon: "logout"
            command: ["hyprctl", "dispatch", "exit"]
        }

        SessionButton {
            icon: "bedtime"
            command: ["systemctl", "suspend"]
        }

        SessionButton {
            icon: "restart_alt"
            command: ["systemctl", "reboot"]
        }

        SessionButton {
            icon: "power_settings_new"
            colour: Colours.palette.m3error
            command: ["systemctl", "poweroff"]
        }
    }

    component SessionButton: StyledRect {
        id: button

        required property string icon
        required property list<string> command
        property color colour: Colours.palette.m3onSurfaceVariant

        implicitWidth: root.buttonSize
        implicitHeight: root.buttonSize

        color: "transparent"
        radius: Appearance.rounding.large

        StateLayer {
            id: stateLayer

            color: button.colour

            onClicked: {
                ShellState.session = false;
                Quickshell.execDetached(button.command);
            }
        }

        MaterialIcon {
            anchors.centerIn: parent
            text: button.icon
            color: button.colour
            size: Appearance.font.size.iconMedium
            fill: stateLayer.containsMouse ? 1 : 0
        }
    }
}
