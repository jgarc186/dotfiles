//
// Storage popout, opened from the bar's disk icon.
//
// What the used space is made of - videos, photos, VM images, caches - and the
// few files that account for most of it. The breakdown comes from a walk of the
// home directory (see services/Disk.qml and scripts/disk-usage) that takes tens
// of seconds, so opening this shows the last result straight away and only
// rescans once that result has gone stale.
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

    readonly property string home: Quickshell.env("HOME")

    implicitWidth: 340
    implicitHeight: layout.implicitHeight + Appearance.padding.large * 2

    color: Colours.tPalette.m3surfaceContainer
    radius: Appearance.rounding.extraLarge

    // df at the fast rate while this is up, and a fresh breakdown if the last
    // one is old
    Component.onCompleted: {
        Disk.watch();
        Disk.scan(false);
    }
    Component.onDestruction: Disk.unwatch()

    function shortPath(path: string): string {
        return path.startsWith(home + "/") ? "~" + path.slice(home.length) : path;
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
                text: "Storage"
                font.pointSize: Appearance.font.size.larger
            }

            StyledText {
                visible: Disk.total > 0
                text: `${Math.round(Disk.usage * 100)}%`
                color: Colours.palette.m3onSurfaceVariant
                font.pointSize: Appearance.font.size.normal
            }

            Item {
                id: refreshButton

                implicitWidth: 32
                implicitHeight: 32

                StateLayer {
                    radius: Appearance.rounding.full
                    color: Colours.palette.m3onSurfaceVariant
                    disabled: Disk.scanning

                    onClicked: Disk.scan(true)
                }

                MaterialIcon {
                    id: refreshIcon

                    anchors.centerIn: parent

                    text: "refresh"
                    color: Colours.palette.m3onSurfaceVariant
                    opacity: Disk.scanning ? 0.5 : 1

                    RotationAnimation on rotation {
                        running: Disk.scanning
                        loops: Animation.Infinite
                        from: 0
                        to: 360
                        duration: Appearance.anim.durations.extraLarge
                        onRunningChanged: if (!running)
                            refreshIcon.rotation = 0
                    }
                }
            }
        }

        UsageBar {
            Layout.fillWidth: true
            Layout.preferredHeight: 10

            fraction: Disk.usage
        }

        StyledText {
            Layout.fillWidth: true

            text: Disk.total > 0 ? `${Disk.formatSize(Disk.used)} used of ${Disk.formatSize(Disk.total)} · ${Disk.formatSize(Disk.available)} free` : "Reading disk…"
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: Appearance.font.size.small
            elide: Text.ElideRight
        }

        // Only before the first scan has finished: after that the previous
        // result stays up while a rescan runs, with the spinning refresh icon
        // saying so
        StyledText {
            Layout.fillWidth: true
            Layout.topMargin: Appearance.padding.large
            Layout.bottomMargin: Appearance.padding.large

            visible: Disk.breakdown.length === 0
            text: Disk.scanning ? "Sorting your files… this takes a little while" : "No breakdown yet"
            color: Colours.palette.m3onSurfaceVariant
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: Appearance.spacing.small

            visible: Disk.breakdown.length > 0
            spacing: Appearance.spacing.small

            Repeater {
                model: Disk.breakdown

                CategoryRow {
                    Layout.fillWidth: true
                }
            }
        }

        StyledText {
            Layout.fillWidth: true
            Layout.topMargin: Appearance.spacing.medium

            visible: Disk.largest.length > 0
            text: "Largest files"
            font.pointSize: Appearance.font.size.normal
        }

        Repeater {
            model: Disk.largest

            RowLayout {
                id: fileRow

                required property var modelData

                readonly property string path: root.shortPath(modelData.path)
                readonly property int slash: path.lastIndexOf("/")

                Layout.fillWidth: true
                spacing: Appearance.spacing.small

                // Name and folder on separate lines: on one line at this width
                // a long name and a long folder elided each other into noise
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    StyledText {
                        Layout.fillWidth: true

                        text: fileRow.path.slice(fileRow.slash + 1)
                        font.pointSize: Appearance.font.size.small
                        elide: Text.ElideMiddle
                    }

                    StyledText {
                        Layout.fillWidth: true

                        text: fileRow.path.slice(0, Math.max(1, fileRow.slash))
                        color: Colours.palette.m3onSurfaceVariant
                        font.pointSize: Appearance.font.size.small
                        elide: Text.ElideMiddle
                    }
                }

                StyledText {
                    Layout.alignment: Qt.AlignTop
                    text: Disk.formatSize(fileRow.modelData.size)
                    font.pointSize: Appearance.font.size.small
                }
            }
        }
    }

    component CategoryRow: RowLayout {
        id: row

        required property var modelData

        spacing: Appearance.spacing.medium

        MaterialIcon {
            Layout.alignment: Qt.AlignVCenter

            text: row.modelData.icon
            color: Colours.palette.m3secondary
            fill: 1
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.extraSmall

            RowLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.small

                StyledText {
                    Layout.fillWidth: true
                    text: row.modelData.label
                    font.pointSize: Appearance.font.size.small
                    elide: Text.ElideRight
                }

                StyledText {
                    text: Disk.formatSize(row.modelData.size)
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: Appearance.font.size.small
                }
            }

            // Against used space rather than the whole disk, so the bars
            // compare categories with each other instead of all reading as
            // slivers on a drive that's mostly empty
            UsageBar {
                Layout.fillWidth: true
                Layout.preferredHeight: 4

                fraction: Disk.used > 0 ? row.modelData.size / Disk.used : 0
                fillColour: Colours.palette.m3secondary
            }
        }
    }

    component UsageBar: StyledRect {
        id: bar

        property real fraction
        property color fillColour: Colours.palette.m3primary

        color: Colours.palette.m3surfaceContainerHighest
        radius: Appearance.rounding.full

        StyledRect {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            // A category too small to show still gets a dot, so its row
            // doesn't look like a bar that failed to draw
            width: Math.max(bar.height, bar.width * Math.min(1, bar.fraction))
            color: bar.fillColour
            radius: Appearance.rounding.full

            Behavior on width {
                Anim {
                    type: Anim.DefaultSpatial
                }
            }
        }
    }
}
