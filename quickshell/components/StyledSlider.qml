//
// Material 3 (expressive) horizontal slider.
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

    // The handle is a bar inset from the ends, with a gap either side, so the
    // track it sits in has to give up that much width
    readonly property real handleWidth: 4
    readonly property real handleGap: 6
    readonly property real trackHeight: 16

    // Centre of the handle
    readonly property real handleX: handleWidth / 2 + Math.max(0, Math.min(1, value)) * (width - handleWidth)

    signal moved(real newValue)

    implicitWidth: 160
    implicitHeight: 40

    function moveTo(x: real): void {
        const span = width - handleWidth;
        if (span <= 0)
            return;
        root.moved(Math.max(0, Math.min(1, (x - handleWidth / 2) / span)));
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

    // Filled portion
    StyledRect {
        anchors.verticalCenter: parent.verticalCenter

        width: Math.max(0, root.handleX - root.handleWidth / 2 - root.handleGap)
        height: root.trackHeight
        radius: Appearance.rounding.full
        color: root.activeColour
    }

    // Remaining portion
    StyledRect {
        anchors.verticalCenter: parent.verticalCenter

        x: root.handleX + root.handleWidth / 2 + root.handleGap
        width: Math.max(0, parent.width - x)
        height: root.trackHeight
        radius: Appearance.rounding.full
        color: root.inactiveColour
    }

    StyledRect {
        anchors.verticalCenter: parent.verticalCenter

        x: root.handleX - root.handleWidth / 2
        width: root.handleWidth
        height: parent.height
        radius: Appearance.rounding.full
        color: root.activeColour
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
