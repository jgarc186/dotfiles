//
// The status pill: volume, network, bluetooth, battery.
//
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config
import qs.services
import qs.utils

StyledRect {
    id: root

    readonly property color colour: Colours.palette.m3secondary

    implicitWidth: Appearance.sizes.bar.innerWidth
    implicitHeight: column.implicitHeight + Appearance.padding.medium * 2

    color: Colours.tPalette.m3surfaceContainer
    radius: Appearance.rounding.full

    ColumnLayout {
        id: column

        anchors.centerIn: parent
        spacing: Appearance.spacing.small

        Repeater {
            model: Config.bar.statusIcons.entries

            Loader {
                required property string modelData

                Layout.alignment: Qt.AlignHCenter

                sourceComponent: {
                    switch (modelData) {
                    case "memory":
                        return memoryComp;
                    case "audio":
                        return audioComp;
                    case "microphone":
                        return micComp;
                    case "network":
                        return networkComp;
                    case "bluetooth":
                        return bluetoothComp;
                    case "battery":
                        return batteryComp;
                    }
                    return null;
                }
            }
        }
    }

    Component {
        id: memoryComp

        HoverIcon {
            icon: "memory"
            tooltip: Mem.summary

            // Only poll every second while the tooltip is actually up
            onHoveredChanged: hovered ? Mem.watch() : Mem.unwatch()
        }
    }

    Component {
        id: audioComp

        MaterialIcon {
            animate: true
            text: Icons.getVolumeIcon(Audio.volume, Audio.muted)
            color: root.colour
            size: Appearance.font.size.iconMedium
            fill: 1
        }
    }

    Component {
        id: micComp

        MaterialIcon {
            animate: true
            text: Icons.getMicIcon(Audio.sourceVolume, Audio.sourceMuted)
            color: root.colour
            size: Appearance.font.size.iconMedium
            fill: 1
        }
    }

    // Hovering names the current network, clicking opens the Wi-Fi popout
    Component {
        id: networkComp

        Item {
            id: net

            readonly property string tooltip: {
                if (Net.ethernet)
                    return "Ethernet";
                if (Net.connected)
                    return `${Net.ssid} \u00b7 ${Net.strength}%`;
                return Net.wifiEnabled ? "Not connected" : "Wi-Fi off";
            }

            implicitWidth: netIcon.implicitWidth
            implicitHeight: netIcon.implicitHeight

            onTooltipChanged: ShellState.updateTooltip(net, tooltip)

            StateLayer {
                // Square the hit area up without stretching the row
                anchors.fill: undefined
                anchors.centerIn: parent
                implicitWidth: implicitHeight
                implicitHeight: netIcon.implicitHeight + Appearance.padding.small
                radius: Appearance.rounding.full
                color: root.colour

                onClicked: ShellState.network = !ShellState.network
                onEntered: ShellState.showTooltip(net, net.tooltip, net.mapToItem(null, 0, net.height / 2).y)
                onExited: ShellState.hideTooltip(net)
            }

            MaterialIcon {
                id: netIcon

                anchors.centerIn: parent

                animate: true
                text: Net.ethernet ? "cable" : Net.connected ? Icons.getNetworkIcon(Net.strength) : "wifi_off"
                color: root.colour
                fill: ShellState.network ? 1 : 0
            }
        }
    }

    Component {
        id: bluetoothComp

        MaterialIcon {
            animate: true
            visible: Bt.enabled || Bt.connected.length > 0
            text: Bt.connected.length > 0 ? Icons.getBluetoothIcon(Bt.connected[0].icon ?? "") : Bt.enabled ? "bluetooth" : "bluetooth_disabled"
            color: root.colour
        }
    }

    // Hovering reports the charge level and, when UPower has an estimate, how
    // long it lasts
    Component {
        id: batteryComp

        HoverIcon {
            visible: Batt.available
            icon: Icons.getBatteryIcon(Batt.percentage, Batt.charging)
            colour: Batt.low ? Colours.palette.m3error : root.colour
            tooltip: Batt.summary
        }
    }

    // An icon that reports something on hover. Deliberately not a StateLayer:
    // its ripple and pointing cursor would promise a popout that these icons
    // don't have.
    component HoverIcon: Item {
        id: hover

        property string icon
        property color colour: root.colour
        // Rebinding this while the bubble is up updates it in place, so a
        // draining battery or a changing memory figure doesn't sit frozen
        property string tooltip
        readonly property alias hovered: hoverArea.containsMouse

        implicitWidth: glyph.implicitWidth
        implicitHeight: glyph.implicitHeight

        onTooltipChanged: ShellState.updateTooltip(hover, tooltip)
        onVisibleChanged: if (!visible)
            ShellState.hideTooltip(hover)

        MouseArea {
            id: hoverArea

            // Square the hit area up without stretching the row
            anchors.centerIn: parent
            implicitWidth: implicitHeight
            implicitHeight: glyph.implicitHeight + Appearance.padding.small

            hoverEnabled: true

            onEntered: ShellState.showTooltip(hover, hover.tooltip, hover.mapToItem(null, 0, hover.height / 2).y)
            onExited: ShellState.hideTooltip(hover)
        }

        MaterialIcon {
            id: glyph

            anchors.centerIn: parent

            animate: true
            text: hover.icon
            color: hover.colour
        }
    }
}
