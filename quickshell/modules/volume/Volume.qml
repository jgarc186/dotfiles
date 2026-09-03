//
// Volume popout, opened from the bar's speaker icon.
//
// Controls the default Pipewire sink only - the same device the volume keys and
// the bar icon already refer to. Sized to sit beside the bar, like the Wi-Fi
// popout and the session menu.
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

    readonly property bool hasSink: Audio.sink?.ready ?? false

    implicitWidth: 300
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
                text: "Volume"
                font.pointSize: Appearance.font.size.larger
            }

            StyledText {
                // Muted, the number is still the level it returns to, so show
                // it greyed rather than hiding it
                text: `${Math.round(Audio.volume * 100)}%`
                color: Audio.muted ? Colours.palette.m3onSurfaceVariant : Colours.palette.m3onSurface
                font.pointSize: Appearance.font.size.normal
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: Appearance.spacing.extraSmall
            spacing: Appearance.spacing.small

            // Doubles as the mute toggle, so the icon that opened the popout is
            // also the control for the one thing a slider can't express
            Item {
                id: muteButton

                implicitWidth: 36
                implicitHeight: 36

                StateLayer {
                    radius: Appearance.rounding.full
                    color: Audio.muted ? Colours.palette.m3error : Colours.palette.m3primary
                    disabled: !root.hasSink

                    onClicked: Audio.toggleMute()
                }

                MaterialIcon {
                    anchors.centerIn: parent

                    animate: true
                    text: Icons.getVolumeIcon(Audio.volume, Audio.muted)
                    color: Audio.muted ? Colours.palette.m3error : Colours.palette.m3primary
                    size: Appearance.font.size.iconMedium
                    fill: 1
                    opacity: root.hasSink ? 1 : 0.5
                }
            }

            StyledSlider {
                Layout.fillWidth: true

                enabled: root.hasSink
                opacity: root.hasSink ? 1 : 0.5
                value: Audio.volume
                stepSize: Audio.stepSize
                activeColour: Audio.muted ? Colours.palette.m3onSurfaceVariant : Colours.palette.m3primary

                // Moving the slider while muted means you want to hear it
                onMoved: newValue => {
                    if (Audio.muted)
                        Audio.toggleMute();
                    Audio.setVolume(newValue);
                }
            }
        }

        StyledText {
            Layout.fillWidth: true
            Layout.topMargin: Appearance.spacing.extraSmall

            text: root.hasSink ? (Audio.sink?.description || Audio.sink?.name || "Unknown device") : "No output device"
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: Appearance.font.size.small
            elide: Text.ElideRight
        }
    }
}
