//
// Horizontal slider: a thin track with a round handle.
//
// Stateless on purpose: `value` is meant to be bound to whatever it controls
// and `moved` is the only way it changes, so the thing being controlled stays
// the single source of truth. Dragging a local copy instead makes the handle
// and the real value drift apart whenever something else moves it (a media key,
// another mixer).
//
import QtQuick
import qs.config
import qs.services

Item {
    id: root

    // 0..1
    property real value: 0
    // How far a wheel notch or an arrow key moves it
    property real stepSize: 0.05
    property color activeColour: Colours.palette.m3primary
    property color inactiveColour: Colours.palette.m3secondaryContainer

    readonly property alias dragging: mouse.pressed

    readonly property real handleSize: 20
    readonly property real trackHeight: 8

    // Centre of the handle. Derived from handleSize rather than the handle's
    // drawn size so that growing it under the pointer doesn't also shift it -
    // the grow is a `scale`, which costs no layout.
    readonly property real handleX: handleSize / 2 + Math.max(0, Math.min(1, value)) * (width - handleSize)

    signal moved(real newValue)

    implicitWidth: 160
    implicitHeight: 40

    function moveTo(x: real): void {
        const span = width - handleSize;
        if (span <= 0)
            return;
        root.moved(Math.max(0, Math.min(1, (x - handleSize / 2) / span)));
    }

    function nudge(steps: real): void {
        root.moved(Math.max(0, Math.min(1, root.value + steps * root.stepSize)));
    }

    Behavior on value {
        // A drag already moves at the pointer's speed; easing it as well makes
        // the handle lag behind the cursor
        enabled: !mouse.pressed
        animation: Anim {
            type: Anim.FastEffects
        }
    }

    // Filled portion, running under the handle to its centre
    StyledRect {
        anchors.verticalCenter: parent.verticalCenter

        width: root.handleX
        height: root.trackHeight
        radius: Appearance.rounding.full
        color: root.activeColour
    }

    // Remaining portion
    StyledRect {
        anchors.verticalCenter: parent.verticalCenter

        x: root.handleX
        width: Math.max(0, parent.width - x)
        height: root.trackHeight
        radius: Appearance.rounding.full
        color: root.inactiveColour
    }

    StyledRect {
        anchors.verticalCenter: parent.verticalCenter

        x: root.handleX - root.handleSize / 2
        width: root.handleSize
        height: root.handleSize
        radius: Appearance.rounding.full
        color: root.activeColour

        // Grows under the pointer, and further while it's being dragged
        scale: mouse.pressed ? 1.2 : mouse.containsMouse ? 1.1 : 1

        Behavior on scale {
            Anim {
                type: Anim.FastSpatial
            }
        }
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onPressed: event => root.moveTo(event.x)
        onPositionChanged: event => {
            if (pressed)
                root.moveTo(event.x);
        }
        onWheel: event => {
            // A horizontal wheel (or a tilt) should read the same way as scroll up
            const delta = event.angleDelta.y !== 0 ? event.angleDelta.y : event.angleDelta.x;
            if (delta !== 0)
                root.nudge(delta > 0 ? 1 : -1);
        }
    }

    // Only reachable where the popout's window takes keyboard focus, which the
    // volume one deliberately doesn't - it's here for whatever does
    Keys.onLeftPressed: root.nudge(-1)
    Keys.onRightPressed: root.nudge(1)
}
