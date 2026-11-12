//
// Notification popups, as a drawer that grows out of the frame's top-right
// corner.
//
// The drawer is painted in the frame's own colour and joined to it by concave
// fillets where it meets the top and right borders, so it doesn't read as a
// window floating over the corner: the frame itself bulges down to hold the
// cards. Caelestia gets that melt from an SDF plugin; for a single drawer
// hanging off two straight edges, one path drawn round it does the same job.
//
// The motion is all height. A new card's slot opens from zero, pushing the ones
// below it down and the drawer's bottom edge with them, so it drops out of the
// frame. A closing card's slot collapses with the card pinned to its bottom
// edge, so the card slides up under whatever is above it - the frame, for the
// top one - and the drawer shrinks after it. The last one to go takes the whole
// drawer back into the border.
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
        // its own size in its path is a binding loop.
        readonly property real r: Math.min(root.rounding, root.height / 2)
        readonly property real edgeLeft: root.rounding
        readonly property real edgeRight: root.rounding + root.width
        readonly property real edgeTop: root.borderTop
        readonly property real edgeBottom: root.borderTop + root.height

        x: -root.rounding
        y: -root.borderTop
        width: root.width + root.rounding + root.borderRight
        height: root.height + root.borderTop + root.rounding

        visible: root.height > 0
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

    // Clipped so a slot that is still opening never draws past the drawer
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

    // A card plus the gap above it. Its height is the animation: the card is
    // pinned to the bottom, so a slot growing from nothing drops the card out
    // of the edge above, and one shrinking to nothing pulls it back up into it.
    component Slot: Item {
        id: slot

        required property Notifs.Notif modelData

        property real progress: 0

        width: column.width
        implicitHeight: (card.implicitHeight + root.padding) * progress
        clip: true

        Component.onCompleted: openAnim.start()

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

        // The springy curve overshoots past 1, so the card drops a little
        // further than its place and settles back
        Anim {
            id: openAnim

            target: slot
            property: "progress"
            to: 1
            type: Anim.SlowSpatial
        }

        // Accelerating out, so it is drawn in rather than eased away
        Anim {
            id: closeAnim

            target: slot
            property: "progress"
            to: 0
            duration: Appearance.anim.durations.normal
            easing.bezierCurve: Appearance.anim.curves.emphasizedAccel

            onFinished: Notifs.absorbed(slot.modelData)
        }

        NotificationCard {
            id: card

            anchors.bottom: parent.bottom
            x: root.padding
            width: parent.width - root.padding * 2

            notif: slot.modelData
            inDrawer: true

            // Fades over the first part of the way in and the last part of the
            // way out, and narrows slightly as it goes into the frame
            opacity: Math.min(1, slot.progress * 1.5)
            scale: 0.92 + 0.08 * Math.min(1, slot.progress)
            transformOrigin: Item.Top
        }
    }
}
