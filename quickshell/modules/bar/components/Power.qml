import QtQuick
import qs.components
import qs.config
import qs.services

Item {
    id: root

    implicitWidth: icon.implicitHeight + Appearance.padding.small
    implicitHeight: icon.implicitHeight

    StateLayer {
        // Square the hit area up without stretching the row
        anchors.fill: undefined
        anchors.centerIn: parent
        implicitWidth: implicitHeight
        implicitHeight: icon.implicitHeight + Appearance.padding.small
        radius: Appearance.rounding.full
        color: Colours.palette.m3error

        onClicked: ShellState.session = !ShellState.session
    }

    MaterialIcon {
        id: icon

        anchors.centerIn: parent

        text: "power_settings_new"
        color: Colours.palette.m3error
        weight: Font.Bold
        fill: ShellState.session ? 1 : 0
    }
}
