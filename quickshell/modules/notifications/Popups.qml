//
// Notification popups, as a drawer that grows out of the frame's top-right
// corner.
//
// The drawer is painted in the frame's own colour and joined to it by concave
// fillets where it meets the top and right borders, so it doesn't read as a
// window floating over the corner: the frame itself bulges out to hold the
// cards. Caelestia gets that melt from an SDF plugin; for a single drawer
// hanging off two straight edges, one path drawn round it does the same job.
//
// Cards move sideways, in and out of the right border. A new one's place in the
// column opens (pushing any below it down) while the card slides in from the
// right; a closing one slides back out to the right, and only then does its
// place close up. The drawer is as wide as its furthest-out card, so the first
// card brings the drawer out of the border with it and the last one takes it
// back in - an empty drawer never drops down from the top edge.
//
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes
import Quickshell
import qs.components
import qs.config
import qs.services

Item {
    id: root

    // How far the frame reaches past the drawer's top and right edges, so the
    // background can overlap it rather than butt up against it
    required property real borderTop
    required property real borderRight

    readonly property int padding: Appearance.padding.medium
    // The frame's inner corner radius, so the fillets match the corner they
    // replace
    readonly property real rounding: Config.border.rounding

    // How far out of the right border the drawer reaches, 0-1: as far as its
    // furthest-out card. Below 1 only while the first card is coming in or the
    // last one going; with any card settled it is the full width.
    readonly property real extent: {
        let furthest = 0;
        for (const child of column.children) {
            const slot = child as Slot;
            if (slot)
                furthest = Math.max(furthest, slot.slide);
        }
        return Math.min(1, furthest);
    }
    readonly property real drawerWidth: width * extent

    // Gap below the last card. Animated on its own, since it appears with the
    // first card and goes with the last, and a snap there undoes the illusion.
    property real bottomPad: column.implicitHeight > 0 ? padding : 0

    implicitWidth: Config.notifs.width + padding * 2
    implicitHeight: column.implicitHeight + bottomPad

    Behavior on bottomPad {
        Anim {
            type: Anim.Emphasized
        }
    }

    Shape {
        id: background

        // Reaches up over the top border, right over the right one and left by
        // one fillet. Sized from root rather than from itself: a Shape reading
        // its own size in its path is a binding loop. The radius also shrinks
        // with the drawer's width, or a drawer narrower than two fillets would
        // draw its bottom corners crossed over.
        readonly property real r: Math.min(root.rounding, root.height / 2, root.drawerWidth / 2)
        readonly property real edgeLeft: root.rounding + root.width - root.drawerWidth
        readonly property real edgeRight: root.rounding + root.width
        readonly property real edgeTop: root.borderTop
        readonly property real edgeBottom: root.borderTop + root.height

        x: -root.rounding
        y: -root.borderTop
        width: root.width + root.rounding + root.borderRight
        height: root.height + root.borderTop + root.rounding

        visible: root.height > 0 && root.drawerWidth > 0
        preferredRendererType: Shape.CurveRenderer
        antialiasing: true

        ShapePath {
            fillColor: Colours.tPalette.m3surface
            strokeWidth: 0
            strokeColor: "transparent"

            // Starts inside the top border, one fillet left of the drawer
            startX: background.edgeLeft - background.r
            startY: 0

            PathLine {
                x: background.edgeLeft - background.r
                y: background.edgeTop
            }

            // Concave: the top border curving down into the drawer's left edge
            PathArc {
                x: background.edgeLeft
                y: background.edgeTop + background.r
                radiusX: background.r
                radiusY: background.r
            }

            PathLine {
                x: background.edgeLeft
                y: background.edgeBottom - background.r
            }

            // Convex: the drawer's one free corner
            PathArc {
                x: background.edgeLeft + background.r
                y: background.edgeBottom
                radiusX: background.r
                radiusY: background.r
                direction: PathArc.Counterclockwise
            }

            PathLine {
                x: background.edgeRight - background.r
                y: background.edgeBottom
            }

            // Concave: the drawer's bottom edge curving down into the right border
            PathArc {
                x: background.edgeRight
                y: background.edgeBottom + background.r
                radiusX: background.r
                radiusY: background.r
            }

            // Back up through the right border and along the top one, which
            // the frame already paints
            PathLine {
                x: background.width
                y: background.edgeBottom + background.r
            }

            PathLine {
                x: background.width
                y: 0
            }

            PathLine {
                x: background.edgeLeft - background.r
                y: 0
            }

            Behavior on fillColor {
                CAnim {}
            }
        }
    }

    // Clipped at the drawer's right edge, which is the right border's inner
    // edge: a card sliding out disappears under the border rather than over it
    Item {
        anchors.fill: parent
        clip: true

        Column {
            id: column

            width: parent.width

            Repeater {
                // A ScriptModel so that a new popup inserts one delegate rather
                // than rebuilding the lot, which would restart every card's
                // entrance at once
                model: ScriptModel {
                    values: [...Notifs.popups]
                }

                Slot {}
            }
        }
    }

    // A card plus the gap above it. `reveal` is how much of its place in the
    // column is open, `slide` how far out of the right border the card is.
    component Slot: Item {
        id: slot

        required property Notifs.Notif modelData

        property real reveal: 0
        property real slide: 0

        width: column.width
        implicitHeight: (card.implicitHeight + root.padding) * reveal
        clip: true

        Component.onCompleted: {
            // Into an empty drawer, which has no width yet: its place can open
            // at once, unseen, so the card and the drawer only move sideways
            if (root.extent === 0)
                reveal = 1;
            openAnim.start();
        }

        Connections {
            target: slot.modelData

            function onPopupChanged(): void {
                if (slot.modelData.popup) {
                    closeAnim.stop();
                    openAnim.start();
                } else {
                    openAnim.stop();
                    closeAnim.start();
                }
            }
        }

        // The place opens while the card is on its way in. Decelerating with
        // no overshoot: past 1, the card would be cut off by the drawer's left
        // edge.
        ParallelAnimation {
            id: openAnim

            Anim {
                target: slot
                property: "reveal"
                to: 1
                type: Anim.Emphasized
            }

            Anim {
                target: slot
                property: "slide"
                to: 1
                duration: Appearance.anim.durations.expressiveDefaultSpatial
                easing.bezierCurve: Appearance.anim.curves.emphasizedDecel
            }
        }

        // Out to the right first, accelerating so it is drawn into the border
        // rather than eased away, and then the gap it left closes
        SequentialAnimation {
            id: closeAnim

            Anim {
                target: slot
                property: "slide"
                to: 0
                duration: Appearance.anim.durations.normal
                easing.bezierCurve: Appearance.anim.curves.emphasizedAccel
            }

            Anim {
                target: slot
                property: "reveal"
                to: 0
                type: Anim.Emphasized
            }

            ScriptAction {
                script: Notifs.absorbed(slot.modelData)
            }
        }

        NotificationCard {
            id: card

            x: root.padding + root.width * (1 - slot.slide)
            y: root.padding
            width: parent.width - root.padding * 2

            notif: slot.modelData
            inDrawer: true
        }
    }
}
