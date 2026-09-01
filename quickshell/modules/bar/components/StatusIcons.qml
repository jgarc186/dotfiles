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

    // The only interactive icon of the lot: hovering names the current network,
    // clicking opens the Wi-Fi popout
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

    Component {
        id: batteryComp

        MaterialIcon {
            animate: true
            visible: Batt.available
            text: Icons.getBatteryIcon(Batt.percentage, Batt.charging)
            color: Batt.low ? Colours.palette.m3error : root.colour
        }
    }
}
