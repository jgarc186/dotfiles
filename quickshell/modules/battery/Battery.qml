//
// Battery popout, opened from the bar's battery icon.
//
// The charge right now, then how worn the battery is: what it holds when full
// against what it held new, how many cycles it has been through, and how warm
// it is. Health comes from UPower; the rest it doesn't pass through, so
// services/Batt.qml reads it from the kernel's power_supply uevent.
//
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config
import qs.services

StyledRect {
    id: root

    // What it held new. sysfs where the driver reports it, else backed out of
    // UPower's health figure - the two agree, see Batt.designEnergy.
    readonly property real designEnergy: Batt.designEnergy > 0 ? Batt.designEnergy : Batt.health > 0 ? Batt.fullEnergy / Batt.health : 0

    readonly property color healthColour: Batt.health >= 0.8 ? Colours.palette.m3primary : Batt.health >= 0.6 ? Colours.palette.m3tertiary : Colours.palette.m3error

    implicitWidth: 320
    implicitHeight: layout.implicitHeight + Appearance.padding.large * 2

    color: Colours.tPalette.m3surfaceContainer
    radius: Appearance.rounding.extraLarge

    // The sysfs figures are only polled while this is up
    Component.onCompleted: Batt.watch()
    Component.onDestruction: Batt.unwatch()

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
                text: "Battery"
                font.pointSize: Appearance.font.size.larger
            }

            StyledText {
                text: `${Math.round(Batt.percentage * 100)}%`
                color: Colours.palette.m3onSurfaceVariant
                font.pointSize: Appearance.font.size.normal
            }
        }

        LevelBar {
            Layout.fillWidth: true
            Layout.preferredHeight: 10

            fraction: Batt.percentage
            fillColour: Batt.low ? Colours.palette.m3error : Colours.palette.m3primary
        }

        StyledText {
            Layout.fillWidth: true

            visible: text !== ""
            text: Batt.status
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: Appearance.font.size.small
            elide: Text.ElideRight
        }

        // Health, on its own raised card since it is what the popout is for
        StyledRect {
            Layout.fillWidth: true
            Layout.topMargin: Appearance.spacing.medium
            implicitHeight: healthLayout.implicitHeight + Appearance.padding.large * 2

            color: Colours.tPalette.m3surfaceContainerHigh
            radius: Appearance.rounding.large

            ColumnLayout {
                id: healthLayout

                anchors.fill: parent
                anchors.margins: Appearance.padding.large

                spacing: Appearance.spacing.small

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Appearance.spacing.small

                    MaterialIcon {
                        text: "ecg_heart"
                        color: root.healthColour
                        fill: 1
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: "Health"
                        font.pointSize: Appearance.font.size.normal
                    }

                    StyledText {
                        visible: Batt.health > 0
                        text: Batt.healthRating
                        color: root.healthColour
                        font.pointSize: Appearance.font.size.small
                    }

                    StyledText {
                        text: Batt.health > 0 ? `${Math.round(Batt.health * 100)}%` : "Unknown"
                        font.pointSize: Appearance.font.size.large
                    }
                }

                LevelBar {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 6

                    visible: Batt.health > 0
                    fraction: Batt.health
                    fillColour: root.healthColour
                }

                StyledText {
                    Layout.fillWidth: true

                    visible: Batt.fullEnergy > 0
                    text: root.designEnergy > 0 ? `Holds ${Batt.fullEnergy.toFixed(1)} Wh of ${root.designEnergy.toFixed(1)} Wh when new` : `Holds ${Batt.fullEnergy.toFixed(1)} Wh when full`
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: Appearance.font.size.small
                    wrapMode: Text.WordWrap
                }
            }
        }

        InfoRow {
            Layout.topMargin: Appearance.spacing.small

            visible: Batt.cycles >= 0
            icon: "cycle"
            label: "Charge cycles"
            value: Batt.cycles.toString()
        }

        InfoRow {
            visible: Batt.temperature >= 0
            icon: "device_thermostat"
            label: "Temperature"
            value: `${(Batt.temperature * 9 / 5 + 32).toFixed(1)} °F`
            // Same roles as the health rating's Fair and Poor
            colour: Batt.hot ? Colours.palette.m3error : Batt.warm ? Colours.palette.m3tertiary : "transparent"
        }

        InfoRow {
            icon: "bolt"
            label: Batt.rate <= 0 ? "Power" : Batt.charging ? "Charge rate" : "Power draw"
            value: Batt.rate > 0 ? `${Batt.rate.toFixed(1)} W` : "Idle"
        }

        InfoRow {
            readonly property string model: [Batt.manufacturer, Batt.battery?.model ?? ""].filter(s => s !== "").join(" ")

            visible: value !== ""
            icon: "info"
            label: "Battery"
            value: [model, Batt.technology].filter(s => s !== "").join(" · ")
        }
    }

    component InfoRow: RowLayout {
        id: row

        property string icon
        property string label
        property string value
        // A warning tint for the whole row; transparent for the normal colours
        property color colour: "transparent"

        Layout.fillWidth: true
        spacing: Appearance.spacing.medium

        MaterialIcon {
            text: row.icon
            color: row.colour.a > 0 ? row.colour : Colours.palette.m3secondary
        }

        StyledText {
            Layout.fillWidth: true
            text: row.label
            font.pointSize: Appearance.font.size.small
        }

        StyledText {
            text: row.value
            color: row.colour.a > 0 ? row.colour : Colours.palette.m3onSurfaceVariant
            font.pointSize: Appearance.font.size.small
        }
    }

    component LevelBar: StyledRect {
        id: bar

        property real fraction
        property color fillColour: Colours.palette.m3primary

        color: Colours.palette.m3surfaceContainerHighest
        radius: Appearance.rounding.full

        StyledRect {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom

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
