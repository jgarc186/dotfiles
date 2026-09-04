//
// The wallpaper carousel, rising out of the bottom edge of the frame.
//
// The PathView arrangement is caelestia-dots/shell's
// modules/launcher/WallpaperList.qml: a straight horizontal path in two
// segments so the middle sample can carry a higher z, the current item held at
// the centre, and an odd item count so there *is* a centre.
//
// Scrolling previews rather than applies. Wallpapers.preview() retints the whole
// shell from a matugen --dry-run; only a click writes anything.
//
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.components
import qs.config
import qs.services

StyledRect {
    id: root

    readonly property int itemWidth: Config.wallpapers.itemWidth + Appearance.padding.medium * 2
    readonly property int arrowSize: 40

    implicitWidth: Math.max(itemWidth, view.implicitWidth) + (arrowSize + Appearance.spacing.small) * 2 + Appearance.padding.large * 2
    implicitHeight: header.height + view.implicitHeight + Appearance.spacing.small + Appearance.padding.large * 2

    color: Colours.tPalette.m3surfaceContainer
    radius: Appearance.rounding.extraLarge

    // Wheel is handled twice on purpose. A WheelHandler on the view is the
    // idiomatic form, but nothing has been seen to arrive through it on this
    // layer surface, and caelestia drives its own scrolling from MouseArea.onWheel
    // instead - so both are wired to the same stepping function. NoButton keeps
    // this one out of the way of the thumbnails' own clicks.
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton

        onWheel: event => view.wheelStep(Math.abs(event.angleDelta.x) > Math.abs(event.angleDelta.y) ? event.angleDelta.x : event.angleDelta.y)
    }

    StyledText {
        id: header

        anchors.top: parent.top
        anchors.topMargin: Appearance.padding.large
        anchors.horizontalCenter: parent.horizontalCenter

        text: Theme.busy ? "Applying…" : "Wallpaper"
        color: Colours.palette.m3onSurfaceVariant
        font.pointSize: Appearance.font.size.normal
    }

    // Clicks are the one input on this panel proven to work end to end, so the
    // carousel gets a pair of them. They are not decoration: the wheel is
    // unreliable here and a drag needs the pointer to already be on a thumbnail.
    Arrow {
        anchors.left: parent.left
        anchors.leftMargin: Appearance.padding.large
        anchors.verticalCenter: view.verticalCenter

        icon: "chevron_left"
        onTriggered: view.decrementCurrentIndex()
    }

    Arrow {
        anchors.right: parent.right
        anchors.rightMargin: Appearance.padding.large
        anchors.verticalCenter: view.verticalCenter

        icon: "chevron_right"
        onTriggered: view.incrementCurrentIndex()
    }

    component Arrow: Item {
        required property string icon

        signal triggered

        implicitWidth: root.arrowSize
        implicitHeight: root.arrowSize

        visible: view.count > 1

        StateLayer {
            radius: Appearance.rounding.full
            color: Colours.palette.m3onSurface

            onClicked: parent.triggered()
        }

        MaterialIcon {
            anchors.centerIn: parent

            text: parent.icon
            color: Colours.palette.m3onSurfaceVariant
            size: Appearance.font.size.iconMedium
        }
    }

    PathView {
        id: view

        anchors.top: header.bottom
        anchors.topMargin: Appearance.spacing.small
        anchors.horizontalCenter: parent.horizontalCenter

        implicitWidth: Math.min(numItems, count) * root.itemWidth
        implicitHeight: currentItem?.implicitHeight ?? Math.round(Config.wallpapers.itemWidth / 16 * 9) + Appearance.padding.large * 2

        // How many fit between the bar and the far edge of the frame. Even counts
        // are dropped by one so that one item is genuinely centred rather than
        // the gap between two being.
        readonly property int numItems: {
            const screen = (QsWindow.window as QsWindow)?.screen;
            if (!screen)
                return 0;

            const margins = Math.max(Config.border.thickness, Appearance.sizes.bar.innerWidth) * 2 + Config.border.rounding * 4;
            const maxWidth = screen.width - margins;
            if (maxWidth <= 0)
                return 0;

            const fits = Math.min(Math.floor(maxWidth / root.itemWidth), Config.wallpapers.maxShown, view.count);
            if (fits === 2)
                return 1;
            if (fits > 1 && fits % 2 === 0)
                return fits - 1;
            return fits;
        }

        model: Wallpapers.list
        pathItemCount: numItems
        cacheItemCount: 4

        snapMode: PathView.SnapToItem
        preferredHighlightBegin: 0.5
        preferredHighlightEnd: 0.5
        highlightRangeMode: PathView.StrictlyEnforceRange

        // Open on the wallpaper in use rather than at whatever sorts first.
        //
        // Tracked rather than set once in onCompleted: the listing is a process,
        // so on the first open the model is still empty when this component is
        // built and there is nothing to find yet - the panel would come up on
        // item 0 every time. Following it also walks the carousel to a wallpaper
        // applied from somewhere else.
        readonly property int currentWallpaper: Wallpapers.list.indexOf(Wallpapers.current)

        onCurrentWallpaperChanged: if (currentWallpaper >= 0)
            currentIndex = currentWallpaper
        Component.onCompleted: if (currentWallpaper >= 0)
            currentIndex = currentWallpaper

        // Closing destroys this, which is the point the preview has to go: the
        // shell would otherwise stay painted in a palette that was never applied
        Component.onDestruction: Wallpapers.stopPreview()

        onCurrentItemChanged: {
            const item = currentItem as WallpaperItem;
            if (item)
                Wallpapers.preview(item.modelData);
        }

        delegate: WallpaperItem {}

        // PathView drags, but it ignores the wheel entirely - and a strip that
        // only responds to dragging reads as static on a desktop.
        //
        // Deltas are accumulated rather than acted on per event: a mouse notch
        // arrives as a single 120, while a touchpad sends a stream of small ones
        // that would otherwise each step a whole wallpaper and fly past the end.
        property real accumulated: 0

        function wheelStep(delta: real): void {
            accumulated += delta;
            while (accumulated <= -120) {
                accumulated += 120;
                incrementCurrentIndex();
            }
            while (accumulated >= 120) {
                accumulated -= 120;
                decrementCurrentIndex();
            }
        }

        WheelHandler {

            onWheel: event => {
                // A vertical wheel is the usual gesture over a horizontal strip;
                // a touchpad two-finger swipe comes in on the other axis, so take
                // whichever moved further.
                view.wheelStep(Math.abs(event.angleDelta.x) > Math.abs(event.angleDelta.y) ? event.angleDelta.x : event.angleDelta.y);
            }
        }

        path: Path {
            startY: view.height / 2

            PathAttribute {
                name: "z"
                value: 0
            }
            PathLine {
                x: view.width / 2
                relativeY: 0
            }
            PathAttribute {
                name: "z"
                value: 1
            }
            PathLine {
                x: view.width
                relativeY: 0
            }
        }
    }
}
