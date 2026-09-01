//
// Distro logo, tinted to the scheme's tertiary colour.
//
import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import qs.components
import qs.config
import qs.services

Item {
    id: root

    readonly property int size: Math.round(Appearance.font.size.large * 1.2)

    implicitWidth: size
    implicitHeight: size

    StateLayer {
        anchors.centerIn: parent
        anchors.fill: undefined
        implicitWidth: root.size + Appearance.padding.small
        implicitHeight: root.size + Appearance.padding.small
        radius: Appearance.rounding.full

        onClicked: Quickshell.execDetached(Config.general.launcherCommand)
    }

    IconImage {
        id: icon

        anchors.fill: parent
        source: SysInfo.osLogo ? Quickshell.iconPath(SysInfo.osLogo, true) : ""
        visible: false
        asynchronous: true
    }

    // Flatten the logo to a single scheme colour, the way caelestia does
    MultiEffect {
        anchors.fill: icon
        source: icon
        colorization: 1
        colorizationColor: Colours.palette.m3tertiary
        visible: icon.status === Image.Ready

        Behavior on colorizationColor {
            CAnim {}
        }
    }

    // Fallback when the distro has no icon theme entry
    MaterialIcon {
        anchors.centerIn: parent
        visible: icon.status !== Image.Ready
        text: "linux"
        size: Appearance.font.size.iconMedium
        color: Colours.palette.m3tertiary
        fill: 1
    }
}
