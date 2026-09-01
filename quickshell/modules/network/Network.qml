//
// Wi-Fi popout, opened from the bar's network icon.
//
// Lists the visible access points and lets you join or leave one. Sized to sit
// beside the bar, like the session menu.
//
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config
import qs.services

StyledRect {
    id: root

    // SSID the password field is asking about, "" when it's hidden
    property string askingFor: ""

    implicitWidth: 320
    implicitHeight: layout.implicitHeight + Appearance.padding.large * 2

    color: Colours.tPalette.m3surfaceContainer
    radius: Appearance.rounding.extraLarge

    // A list that's minutes stale is worse than useless, so kick off a scan
    // as the popout opens
    Component.onCompleted: {
        Net.lastError = "";
        Net.scan();
    }

    function activate(network: var): void {
        Net.lastError = "";

        if (network.active) {
            Net.disconnect();
            return;
        }

        // A saved profile already holds the password; an open network needs none
        if (network.secured && !network.known) {
            root.askingFor = network.ssid;
            return;
        }

        root.askingFor = "";
        Net.connectTo(network.ssid, "");
    }

    // An attempt that failed on a network we thought we knew means the saved
    // password is wrong (or gone), so ask for it rather than failing silently
    Connections {
        target: Net

        function onConnectingChanged(): void {
            if (Net.connecting)
                return;
            root.askingFor = Net.lastError === "" ? "" : Net.pendingSsid;
        }
    }

    ColumnLayout {
        id: layout

        anchors.fill: parent
        anchors.margins: Appearance.padding.large

        spacing: Appearance.spacing.small

        RowLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.small

            StyledText {
                Layout.fillWidth: true
                text: "Wi-Fi"
                font.pointSize: Appearance.font.size.larger
            }

            HeaderButton {
                id: refreshButton

                icon: "refresh"
                enabled: !Net.scanning
                onClicked: Net.scan()

                RotationAnimation on rotation {
                    running: Net.scanning
                    loops: Animation.Infinite
                    from: 0
                    to: 360
                    duration: Appearance.anim.durations.extraLarge
                    onRunningChanged: if (!running)
                        refreshButton.rotation = 0
                }
            }

            HeaderButton {
                icon: Net.wifiEnabled ? "wifi" : "wifi_off"
                accent: Net.wifiEnabled
                onClicked: Net.setWifiEnabled(!Net.wifiEnabled)
            }
        }

        StyledText {
            Layout.fillWidth: true
            Layout.topMargin: Appearance.padding.large
            Layout.bottomMargin: Appearance.padding.large

            visible: Net.networks.length === 0
            text: Net.wifiEnabled ? "No networks found" : "Wi-Fi is off"
            color: Colours.palette.m3onSurfaceVariant
            horizontalAlignment: Text.AlignHCenter
        }

        ListView {
            id: list

            Layout.fillWidth: true
            // Grows with the list, up to a height that still leaves the popout
            // shorter than a typical screen
            Layout.preferredHeight: Math.min(contentHeight, 360)

            visible: Net.networks.length > 0
            clip: true
            spacing: Appearance.spacing.extraSmall
            model: Net.networks

            delegate: NetworkItem {
                width: list.width

                onActivated: root.activate(modelData)
            }
        }

        StyledText {
            Layout.fillWidth: true

            visible: Net.lastError !== ""
            text: Net.lastError
            color: Colours.palette.m3error
            font.pointSize: Appearance.font.size.small
            wrapMode: Text.WordWrap
        }

        // Password entry, shown only for a network that needs one
        StyledRect {
            Layout.fillWidth: true
            Layout.preferredHeight: 40

            visible: root.askingFor !== ""
            color: Colours.tPalette.m3surfaceContainerHigh
            radius: Appearance.rounding.full

            onVisibleChanged: {
                password.text = "";
                if (visible)
                    password.forceActiveFocus();
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Appearance.padding.medium
                anchors.rightMargin: Appearance.padding.extraSmall

                spacing: Appearance.spacing.small

                TextInput {
                    id: password

                    Layout.fillWidth: true

                    color: Colours.palette.m3onSurface
                    font.family: Appearance.font.family.sans
                    font.pointSize: Appearance.font.size.normal
                    echoMode: TextInput.Password
                    selectByMouse: true
                    selectionColor: Colours.palette.m3primary
                    selectedTextColor: Colours.palette.m3onPrimary

                    onAccepted: Net.connectTo(root.askingFor, text)

                    Keys.onEscapePressed: root.askingFor = ""

                    StyledText {
                        anchors.verticalCenter: parent.verticalCenter

                        visible: password.text === ""
                        text: `Password for ${root.askingFor}`
                        color: Colours.palette.m3onSurfaceVariant
                        elide: Text.ElideRight
                        width: password.width
                    }
                }

                HeaderButton {
                    icon: "arrow_forward"
                    accent: true
                    enabled: !Net.connecting
                    onClicked: Net.connectTo(root.askingFor, password.text)
                }
            }
        }
    }

    component HeaderButton: Item {
        id: button

        required property string icon
        property bool accent: false

        signal clicked

        implicitWidth: 32
        implicitHeight: 32

        StateLayer {
            radius: Appearance.rounding.full
            color: button.accent ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
            disabled: !button.enabled

            onClicked: button.clicked()
        }

        MaterialIcon {
            anchors.centerIn: parent

            text: button.icon
            color: button.accent ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
            opacity: button.enabled ? 1 : 0.5
        }
    }
}
