//
// The bar's contents, top to bottom.
//
// Order comes from Config.bar.entries; "spacer" absorbs the leftover height, so
// everything after it is pinned to the bottom.
//
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import "components"
import "components/workspaces"
import qs.config

ColumnLayout {
    id: root

    required property ShellScreen screen

    readonly property int vPadding: Appearance.padding.large

    spacing: Appearance.spacing.medium

    Repeater {
        id: repeater

        model: Config.bar.entries

        Item {
            id: entry

            required property string modelData
            required property int index

            readonly property bool isSpacer: modelData === "spacer"

            Layout.topMargin: index === 0 ? root.vPadding : 0
            Layout.bottomMargin: index === repeater.count - 1 ? root.vPadding : 0
            Layout.alignment: Qt.AlignHCenter
            Layout.fillHeight: isSpacer

            readonly property Item content: loader.item as Item

            visible: isSpacer || (content?.visible ?? true)
            implicitWidth: content?.implicitWidth ?? 0
            implicitHeight: content?.implicitHeight ?? 0

            Loader {
                id: loader

                anchors.centerIn: parent
                active: !entry.isSpacer

                sourceComponent: {
                    switch (entry.modelData) {
                    case "logo":
                        return logoComp;
                    case "workspaces":
                        return workspacesComp;
                    case "tray":
                        return trayComp;
                    case "statusIcons":
                        return statusIconsComp;
                    case "themeMode":
                        return themeModeComp;
                    case "clock":
                        return clockComp;
                    case "power":
                        return powerComp;
                    }
                    return null;
                }
            }
        }
    }

    Component {
        id: logoComp

        OsIcon {}
    }

    Component {
        id: workspacesComp

        Workspaces {
            screen: root.screen
        }
    }

    Component {
        id: trayComp

        Tray {}
    }

    Component {
        id: statusIconsComp

        StatusIcons {}
    }

    Component {
        id: themeModeComp

        ThemeToggle {}
    }

    Component {
        id: clockComp

        Clock {}
    }

    Component {
        id: powerComp

        Power {}
    }
}
