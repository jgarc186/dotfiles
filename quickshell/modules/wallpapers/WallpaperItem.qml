//
// One wallpaper in the carousel.
//
// Ported from caelestia-dots/shell's modules/launcher/items/WallpaperItem.qml,
// with its three plugin-backed pieces swapped for stock equivalents: a plain
// asynchronous Image instead of CachingImage, a MultiEffect shadow instead of
// Elevation, and a path string instead of a FileSystemEntry.
//
import QtQuick
import QtQuick.Effects
import qs.components
import qs.config
import qs.services

Item {
    id: root

    required property string modelData

    readonly property bool isCurrent: PathView.isCurrentItem
    readonly property bool onPath: PathView.onPath

    // Attached values named by a PathAttribute are created by the view at
    // runtime, so the linter can't know "z" is one of them.
    // qmllint disable missing-property
    z: PathView.z ?? 0
    // qmllint enable missing-property

    // Bound in onCompleted rather than declared inline so that a delegate built
    // as the view scrolls animates in from these starting values instead of
    // appearing at its final size
    scale: 0.5
    opacity: 0

    Component.onCompleted: {
        scale = Qt.binding(() => root.isCurrent ? 1 : root.onPath ? 0.8 : 0);
        opacity = Qt.binding(() => root.onPath ? 1 : 0);
    }

    implicitWidth: image.implicitWidth + Appearance.padding.medium * 2
    implicitHeight: image.implicitHeight + label.height + Appearance.spacing.extraSmall + Appearance.padding.large + Appearance.padding.medium

    StateLayer {
        radius: Appearance.rounding.large
        color: Colours.palette.m3onSurface
        disabled: Theme.busy

        onClicked: {
            Wallpapers.setWallpaper(root.modelData);
            ShellState.wallpapers = false;
        }
    }

    // Lifts the centred item off the row. Sits behind the image rather than on
    // it: MultiEffect renders its source, so putting it on top would double the
    // thumbnail over its own shadow.
    MultiEffect {
        anchors.fill: image

        source: image
        opacity: root.isCurrent ? 1 : 0
        shadowEnabled: true
        shadowColor: Colours.palette.m3shadow
        shadowVerticalOffset: 2
        blurMax: 16

        Behavior on opacity {
            Anim {
                type: Anim.DefaultEffects
            }
        }
    }

    StyledClippingRect {
        id: image

        anchors.horizontalCenter: parent.horizontalCenter
        y: Appearance.padding.large

        color: Colours.tPalette.m3surfaceContainerHigh
        radius: Appearance.rounding.large

        implicitWidth: Config.wallpapers.itemWidth
        implicitHeight: Math.round(implicitWidth / 16 * 9)

        // Shows through until the image has decoded, which is not instant: some
        // of these files are 8-10MB
        MaterialIcon {
            anchors.centerIn: parent

            text: "image"
            color: Colours.palette.m3outline
            size: Appearance.font.size.extraLarge
        }

        Image {
            anchors.fill: parent

            source: Wallpapers.fileUrl(root.modelData)
            fillMode: Image.PreserveAspectCrop
            // Decoding on the render thread instead of blocking the flick
            asynchronous: true
            // Smoothing every frame of a moving carousel costs more than it shows
            smooth: !root.PathView.view.moving
            // Without this the full-resolution image is kept in memory per item
            sourceSize.width: image.implicitWidth * Screen.devicePixelRatio
            sourceSize.height: image.implicitHeight * Screen.devicePixelRatio
        }
    }

    // The committed wallpaper, so the panel says which one you are actually on
    // rather than only which one is centred
    StyledRect {
        anchors.fill: image

        color: "transparent"
        radius: image.radius
        border.width: 2
        border.color: Colours.palette.m3primary
        opacity: root.modelData === Wallpapers.current ? 1 : 0

        Behavior on opacity {
            Anim {
                type: Anim.DefaultEffects
            }
        }
    }

    StyledText {
        id: label

        anchors.top: image.bottom
        anchors.topMargin: Appearance.spacing.extraSmall
        anchors.horizontalCenter: parent.horizontalCenter

        width: image.width - Appearance.padding.medium * 2
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        text: Wallpapers.basename(root.modelData)
        color: root.isCurrent ? Colours.palette.m3onSurface : Colours.palette.m3onSurfaceVariant
        font.pointSize: Appearance.font.size.small
    }

    Behavior on scale {
        Anim {}
    }

    Behavior on opacity {
        Anim {
            type: Anim.DefaultEffects
        }
    }
}
