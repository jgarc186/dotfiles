import QtQuick
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.components
import qs.config

Item {
    id: root

    required property SystemTrayItem modelData

    readonly property int size: Appearance.font.size.iconSmall + Appearance.padding.small

    implicitWidth: size
    implicitHeight: size

    StateLayer {
        radius: Appearance.rounding.full
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton

        onClicked: event => {
            if (event.button === Qt.MiddleButton)
                root.modelData.secondaryActivate();
            else if (root.modelData.onlyMenu)
                root.modelData.display(root, 0, 0);
            else
                root.modelData.activate();
        }
    }

    IconImage {
        anchors.centerIn: parent
        implicitSize: Math.round(parent.size * 0.7)
        source: root.modelData.icon
        asynchronous: true
    }
}
