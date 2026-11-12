//
// Notification history, opened from the bar's bell - swaync's control centre,
// sized to sit beside the bar like the other popouts.
//
// Holds everything the server still tracks: popups that timed out or were
// clicked away land here, and leave only when dismissed (or cleared, or pushed
// out by Config.notifs.maxHistory). Also where do-not-disturb lives.
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

    implicitWidth: Config.notifs.width + Appearance.padding.large * 2
    implicitHeight: layout.implicitHeight + Appearance.padding.large * 2

    color: Colours.tPalette.m3surfaceContainer
    radius: Appearance.rounding.extraLarge

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
                text: Notifs.count > 0 ? `Notifications · ${Notifs.count}` : "Notifications"
                font.pointSize: Appearance.font.size.larger
            }

            IconButton {
                icon: Notifs.dnd ? "notifications_off" : "notifications_active"
                colour: Notifs.dnd ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
                fill: Notifs.dnd ? 1 : 0

                onClicked: Notifs.dnd = !Notifs.dnd
            }

            IconButton {
                icon: "clear_all"
                enabled: Notifs.count > 0

                onClicked: Notifs.clear()
            }
        }

        StyledText {
            Layout.fillWidth: true

            visible: Notifs.dnd
            text: "Do not disturb · only critical notifications pop up"
            color: Colours.palette.m3primary
            font.pointSize: Appearance.font.size.small
            elide: Text.ElideRight
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: Appearance.padding.large
            Layout.bottomMargin: Appearance.padding.large

            visible: Notifs.count === 0
            spacing: Appearance.spacing.small

            MaterialIcon {
                Layout.alignment: Qt.AlignHCenter
                text: "notifications_none"
                color: Colours.palette.m3onSurfaceVariant
                size: Appearance.font.size.iconLarge
            }

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: "All caught up"
                color: Colours.palette.m3onSurfaceVariant
            }
        }

        ListView {
            id: list

            Layout.fillWidth: true
            // Grows with the history, up to a height that still leaves the
            // popout shorter than a typical screen
            Layout.preferredHeight: Math.min(contentHeight, 480)

            visible: Notifs.count > 0
            clip: true
            spacing: Appearance.spacing.small
            boundsBehavior: Flickable.StopAtBounds

            // A ScriptModel diffs, so a dismissal removes one row and the
            // transitions below get to run instead of the list rebuilding
            model: ScriptModel {
                values: [...Notifs.list]
            }

            delegate: NotificationCard {
                required property Notifs.Notif modelData

                width: list.width
                notif: modelData
                color: Colours.tPalette.m3surfaceContainerHigh
            }

            add: Transition {
                Anim {
                    property: "opacity"
                    from: 0
                    to: 1
                    type: Anim.DefaultEffects
                }
            }

            // Swept off to the side it was closed from
            remove: Transition {
                Anim {
                    property: "x"
                    to: list.width
                    type: Anim.Emphasized
                }
                Anim {
                    property: "opacity"
                    to: 0
                    type: Anim.DefaultEffects
                }
            }

            displaced: Transition {
                Anim {
                    property: "y"
                    type: Anim.DefaultSpatial
                }
            }
        }
    }
}
