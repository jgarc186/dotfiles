pragma ComponentBehavior: Bound
//
// Vertical clock: day-of-week, date, then hours over minutes.
//
import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config
import qs.services

StyledRect {
    id: root

    readonly property color colour: Colours.palette.m3tertiary
    readonly property int padding: Config.bar.clock.background ? Appearance.padding.medium : Appearance.padding.extraSmall

    implicitWidth: Appearance.sizes.bar.innerWidth
    implicitHeight: layout.implicitHeight + padding * 2

    color: Config.bar.clock.background ? Colours.tPalette.m3surfaceContainer : "transparent"
    radius: Appearance.rounding.full

    ColumnLayout {
        id: layout

        anchors.centerIn: parent
        spacing: Appearance.spacing.extraSmall

        Loader {
            Layout.alignment: Qt.AlignHCenter
            active: Config.bar.clock.showIcon
            visible: active

            sourceComponent: MaterialIcon {
                text: "calendar_month"
                color: root.colour
            }
        }

        Loader {
            Layout.alignment: Qt.AlignHCenter
            active: Config.bar.clock.showDate
            visible: active

            sourceComponent: ColumnLayout {
                spacing: 0

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: Time.format("ddd")
                    color: root.colour
                    font.family: Appearance.font.family.clock
                    font.pointSize: Appearance.font.size.small
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: Time.format("d")
                    color: root.colour
                    font.family: Appearance.font.family.clock
                    font.pointSize: Appearance.font.size.normal
                }

                // Hairline rule between the date and the time
                StyledRect {
                    Layout.fillWidth: true
                    Layout.leftMargin: -Appearance.padding.extraSmall
                    Layout.rightMargin: -Appearance.padding.extraSmall
                    Layout.topMargin: 3
                    Layout.bottomMargin: 2
                    implicitHeight: 1
                    color: Colours.palette.m3outlineVariant
                }
            }
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: Time.hourStr
            color: root.colour
            font.family: Appearance.font.family.clock
            font.pointSize: Appearance.font.size.larger
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: -layout.spacing - 3
            text: Time.minuteStr
            color: root.colour
            font.family: Appearance.font.family.clock
            font.pointSize: Appearance.font.size.larger
        }

        Loader {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: -layout.spacing - 2
            active: Config.general.useTwelveHourClock
            visible: active

            sourceComponent: StyledText {
                text: Time.amPmStr.toLowerCase()
                color: root.colour
                font.family: Appearance.font.family.clock
                font.pointSize: Appearance.font.size.small
            }
        }
    }
}
