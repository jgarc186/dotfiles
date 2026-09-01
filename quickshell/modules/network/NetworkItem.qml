//
// One access point row in the Wi-Fi popout.
//
import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config
import qs.services
import qs.utils

StyledRect {
    id: root

    required property var modelData

    readonly property bool active: root.modelData.active
    readonly property bool known: root.modelData.known
    readonly property bool secured: root.modelData.secured
    readonly property color fg: active ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface

    signal activated

    implicitHeight: row.implicitHeight + Appearance.padding.small * 2

    color: active ? Colours.palette.m3secondaryContainer : "transparent"
    radius: Appearance.rounding.large

    StateLayer {
        color: root.fg

        onClicked: root.activated()
    }

    RowLayout {
        id: row

        anchors.fill: parent
        anchors.leftMargin: Appearance.padding.small
        anchors.rightMargin: Appearance.padding.small

        spacing: Appearance.spacing.small

        MaterialIcon {
            text: Icons.getNetworkIcon(root.modelData.strength)
            color: root.fg
            fill: root.active ? 1 : 0
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            StyledText {
                Layout.fillWidth: true
                text: root.modelData.ssid
                color: root.fg
                elide: Text.ElideRight
            }

            StyledText {
                Layout.fillWidth: true
                text: root.active ? "Connected" : root.known ? "Saved" : root.secured ? "Secured" : "Open"
                color: root.active ? root.fg : Colours.palette.m3onSurfaceVariant
                font.pointSize: Appearance.font.size.small
                elide: Text.ElideRight
            }
        }

        // Only flag networks that will ask for something: a password to join,
        // or a click to leave
        MaterialIcon {
            text: root.active ? "link_off" : "lock"
            visible: root.active || (root.secured && !root.known)
            color: root.fg
        }
    }
}
