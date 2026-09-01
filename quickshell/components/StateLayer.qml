//
// Material 3 state layer: hover tint plus a press ripple.
//
// Sits on top of whatever it's a child of and inherits that parent's corner
// radii, so it can be dropped into any rounded surface without configuration.
//
import QtQuick
import QtQuick.Shapes
import qs.config
import qs.services

MouseArea {
    id: root

    property bool disabled
    property color color: Colours.palette.m3onSurface
    // Picks up the radius of whatever rounded surface it's dropped into
    // qmllint disable missing-property
    property real radius: root.parent?.radius ?? 0
    // qmllint enable missing-property

    property real hoverOpacity: containsMouse ? 0.08 : 0

    property real pressX: width / 2
    property real pressY: height / 2
    property real rippleRadius

    // Furthest corner from the press point - how far the ripple has to travel
    readonly property real endRadius: {
        const d = (x, y) => (pressX - x) ** 2 + (pressY - y) ** 2;
        return Math.sqrt(Math.max(d(0, 0), d(width, 0), d(0, height), d(width, height))) * 1.3;
    }

    anchors.fill: parent
    enabled: !disabled
    hoverEnabled: true
    cursorShape: disabled ? undefined : Qt.PointingHandCursor

    onPressed: event => {
        pressX = event.x;
        pressY = event.y;
        fadeAnim.complete();
        rippleRadius = 0;
        ripple.opacity = 0.1;
        rippleAnim.restart();
    }

    onReleased: fadeAnim.restart()
    onCanceled: fadeAnim.restart()

    StyledRect {
        anchors.fill: parent
        radius: root.radius
        color: root.color
        opacity: root.hoverOpacity

        Behavior on opacity {
            Anim {
                type: Anim.DefaultEffects
            }
        }
    }

    Shape {
        id: ripple

        anchors.fill: parent
        opacity: 0
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeWidth: 0
            strokeColor: "transparent"
            fillColor: root.color

            // Clip the ripple to the rounded parent by filling only the rounded
            // rect, and let the gradient do the expanding circle.
            fillGradient: RadialGradient {
                centerX: root.pressX
                centerY: root.pressY
                centerRadius: Math.max(0.01, root.rippleRadius)
                focalX: centerX
                focalY: centerY

                GradientStop {
                    position: 0
                    color: Qt.alpha(root.color, 1)
                }
                GradientStop {
                    position: 0.99
                    color: Qt.alpha(root.color, 1)
                }
                GradientStop {
                    position: 1
                    color: "transparent"
                }
            }

            PathRectangle {
                width: root.width
                height: root.height
                radius: Math.min(root.radius, root.width / 2, root.height / 2)
            }
        }
    }

    Anim {
        id: rippleAnim

        alwaysRunToEnd: true
        target: root
        property: "rippleRadius"
        to: root.endRadius
        type: Anim.SlowEffects
        duration: Appearance.anim.durations.expressiveSlowEffects * 2
    }

    Anim {
        id: fadeAnim

        target: ripple
        property: "opacity"
        to: 0
        type: Anim.SlowEffects
    }
}
