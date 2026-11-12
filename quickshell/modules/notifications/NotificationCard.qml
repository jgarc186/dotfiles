//
// One notification: icon or image, app and age, summary, body, action buttons.
//
// The same card is a popup in the top-right drawer and a row in the history
// popout; `inDrawer` is the only difference. Everything it draws comes from the
// Notif wrapper, never from the server's Notification, so a card mid-absorb
// still has text to show after the notification behind it has closed.
//
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config
import qs.services

StyledRect {
    id: root

    required property Notifs.Notif notif
    property bool inDrawer: false

    readonly property int iconSize: 40
    // Typed, so the Image sources below get a string rather than whatever the
    // null-safe read produces
    readonly property string image: notif?.image ?? ""
    readonly property string icon: notif?.icon ?? ""

    implicitHeight: layout.implicitHeight + Appearance.padding.medium * 2

    color: Colours.tPalette.m3surfaceContainer
    radius: Appearance.rounding.large

    // The pointer on a popup holds its timeout, the way swaync's did
    HoverHandler {
        onHoveredChanged: if (root.inDrawer)
            root.notif.hovered = hovered
    }

    // A card destroyed under the pointer never sees it leave
    Component.onDestruction: if (inDrawer && notif)
        notif.hovered = false

    // Bindings below read `root.notif?.` because a reload destroys the Notifs
    // singleton - and every wrapper with it - before the cards showing them,
    // and each binding re-evaluates once against null on the way down

    // The card's own click: the sender's default action if it has one.
    // Otherwise a popup is just sent on its way into the frame, which keeps it
    // in the history - the close button is the one that throws it away.
    StateLayer {
        disabled: !root.inDrawer && !root.notif?.hasDefault

        onClicked: {
            if (root.notif.hasDefault)
                root.notif.invoke("default");
            else
                root.notif.popup = false;
        }
    }

    RowLayout {
        id: layout

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Appearance.padding.medium

        spacing: Appearance.spacing.medium

        Item {
            Layout.alignment: Qt.AlignTop
            implicitWidth: root.iconSize
            implicitHeight: root.iconSize

            StyledClippingRect {
                anchors.fill: parent

                radius: Appearance.rounding.full
                color: root.notif?.critical ? Colours.palette.m3errorContainer : Colours.palette.m3secondaryContainer

                // A picture the sender attached - an avatar, an album cover
                Image {
                    id: picture

                    anchors.fill: parent

                    visible: status === Image.Ready
                    source: root.image
                    sourceSize.width: root.iconSize * 2
                    sourceSize.height: root.iconSize * 2
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                }

                Image {
                    id: appIcon

                    anchors.centerIn: parent
                    width: root.iconSize * 0.6
                    height: width

                    visible: !picture.visible && status === Image.Ready
                    source: root.icon
                    sourceSize.width: width * 2
                    sourceSize.height: height * 2
                    asynchronous: true
                }

                MaterialIcon {
                    anchors.centerIn: parent

                    visible: !picture.visible && !appIcon.visible
                    text: root.notif?.critical ? "priority_high" : "notifications"
                    color: root.notif?.critical ? Colours.palette.m3onErrorContainer : Colours.palette.m3onSecondaryContainer
                    size: Appearance.font.size.iconMedium
                    fill: 1
                }
            }

            // With a picture in the circle, the app's icon moves to a badge
            StyledRect {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: -2

                implicitWidth: 18
                implicitHeight: 18

                visible: picture.visible && badge.status === Image.Ready
                color: root.color
                radius: Appearance.rounding.full

                Image {
                    id: badge

                    anchors.centerIn: parent
                    width: 14
                    height: 14

                    source: picture.visible ? root.icon : ""
                    sourceSize.width: 28
                    sourceSize.height: 28
                    asynchronous: true
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            RowLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.small

                StyledText {
                    Layout.fillWidth: true

                    // Reads the clock so the age ticks over by itself
                    text: {
                        if (!root.notif)
                            return "";
                        const age = Notifs.ago(root.notif.time, Time.date);
                        return root.notif.appName ? `${root.notif.appName} · ${age}` : age;
                    }
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: Appearance.font.size.small
                    elide: Text.ElideRight
                }

                IconButton {
                    icon: "close"
                    size: Appearance.font.size.iconSmall * 0.8

                    onClicked: root.notif.dismiss()
                }
            }

            StyledText {
                Layout.fillWidth: true

                text: root.notif?.summary ?? ""
                color: root.notif?.critical ? Colours.palette.m3error : Colours.palette.m3onSurface
                font.pointSize: Appearance.font.size.normal
                font.weight: Font.Medium
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }

            StyledText {
                Layout.fillWidth: true
                Layout.topMargin: 2

                visible: text !== ""
                // The server advertises markup, so senders send <b>, <i> and
                // links; StyledText renders those and nothing riskier
                textFormat: Text.StyledText
                text: root.notif?.body ?? ""
                color: Colours.palette.m3onSurfaceVariant
                linkColor: Colours.palette.m3primary
                font.pointSize: Appearance.font.size.smaller
                wrapMode: Text.Wrap
                maximumLineCount: Config.notifs.bodyLines
                elide: Text.ElideRight

                onLinkActivated: link => Qt.openUrlExternally(link)
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: Appearance.spacing.small

                visible: (root.notif?.buttons.length ?? 0) > 0
                spacing: Appearance.spacing.small

                Repeater {
                    model: root.notif?.buttons ?? []

                    StyledRect {
                        id: action

                        required property var modelData

                        Layout.fillWidth: true
                        implicitHeight: 32
                        implicitWidth: label.implicitWidth + Appearance.padding.large * 2

                        color: Colours.palette.m3secondaryContainer
                        radius: Appearance.rounding.full

                        StateLayer {
                            color: Colours.palette.m3onSecondaryContainer

                            onClicked: root.notif.invoke(action.modelData.identifier)
                        }

                        StyledText {
                            id: label

                            anchors.centerIn: parent
                            width: Math.min(implicitWidth, action.width - Appearance.padding.medium * 2)

                            text: action.modelData.text
                            color: Colours.palette.m3onSecondaryContainer
                            font.pointSize: Appearance.font.size.smaller
                            font.weight: Font.Medium
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }
    }
}
