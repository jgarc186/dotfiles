//
// Material 3 expressive shapes, with a morph animation between them.
//
// Upstream caelestia gets these from a C++ plugin. Here each shape is a polar
// radius function sampled at a fixed set of angles, which makes morphing free:
// two shapes sampled at the same angles interpolate elementwise, exactly the
// shape-interpolation M3 specifies. Polygons get their corners rounded by a
// moving average over the sampled radii.
//
import QtQuick
import QtQuick.Shapes

Shape {
    id: root

    enum Shape {
        Circle,
        Oval,
        Square,
        Slanted,
        Pill,
        Triangle,
        Diamond,
        Pentagon,
        Gem,
        Cookie4Sided,
        Cookie6Sided,
        Cookie7Sided,
        Cookie9Sided,
        Cookie12Sided,
        Clover4Leaf,
        SoftBurst,
        Sunny,
        VerySunny
    }

    property int shape: MaterialShape.Circle
    property color color: "white"
    property real implicitSize: 20
    readonly property int samples: 120

    // Elementwise interpolation between the previous shape and the current one
    property var fromRadii: radiiFor(shape)
    property var toRadii: radiiFor(shape)
    property real morph: 1

    implicitWidth: implicitSize
    implicitHeight: implicitSize

    preferredRendererType: Shape.CurveRenderer
    antialiasing: true

    function radiiFor(shape: int): var {
        const n = samples;
        const tau = Math.PI * 2;
        const raw = [];

        // JS % keeps the sign of the dividend, which breaks the polygon fold
        // below for any negative rotation (i.e. every odd-sided shape).
        const mod = (x, m) => ((x % m) + m) % m;
        // Distance from centre to the edge of a regular N-gon at angle a
        const polygon = (a, sides, rot) => {
            const seg = tau / sides;
            const half = seg / 2;
            return Math.cos(half) / Math.cos(mod(a + rot, seg) - half);
        };
        // Superellipse: exponent 4 is a squircle, higher is squarer
        const superellipse = (a, exp, aspect) => {
            const c = Math.abs(Math.cos(a));
            const s = Math.abs(Math.sin(a)) / aspect;
            return (c ** exp + s ** exp) ** (-1 / exp);
        };
        // Scalloped "cookie": N lobes of depth amp
        const cookie = (a, lobes, amp) => 1 - amp + amp * Math.cos(lobes * a);

        for (let i = 0; i < n; i++) {
            const a = (i / n) * tau;

            switch (shape) {
            case MaterialShape.Circle:
                raw.push(1);
                break;
            case MaterialShape.Oval:
                raw.push(superellipse(a, 2, 0.78));
                break;
            case MaterialShape.Square:
                raw.push(superellipse(a, 4, 1));
                break;
            case MaterialShape.Slanted:
                raw.push(superellipse(a + Math.PI / 8, 4, 1));
                break;
            case MaterialShape.Pill:
                raw.push(superellipse(a + Math.PI / 2, 8, 0.62));
                break;
            case MaterialShape.Triangle:
                raw.push(polygon(a, 3, -Math.PI / 2));
                break;
            case MaterialShape.Diamond:
                raw.push(polygon(a, 4, 0));
                break;
            case MaterialShape.Pentagon:
                raw.push(polygon(a, 5, -Math.PI / 2));
                break;
            case MaterialShape.Gem:
                raw.push(polygon(a, 6, Math.PI / 6));
                break;
            case MaterialShape.Cookie4Sided:
                raw.push(cookie(a, 4, 0.14));
                break;
            case MaterialShape.Cookie6Sided:
                raw.push(cookie(a, 6, 0.12));
                break;
            case MaterialShape.Cookie7Sided:
                raw.push(cookie(a, 7, 0.11));
                break;
            case MaterialShape.Cookie9Sided:
                raw.push(cookie(a, 9, 0.1));
                break;
            case MaterialShape.Cookie12Sided:
                raw.push(cookie(a, 12, 0.08));
                break;
            case MaterialShape.Clover4Leaf:
                raw.push(cookie(a, 4, 0.24));
                break;
            case MaterialShape.SoftBurst:
                raw.push(cookie(a, 10, 0.12));
                break;
            case MaterialShape.Sunny:
                raw.push(cookie(a, 8, 0.2));
                break;
            case MaterialShape.VerySunny:
                raw.push(cookie(a, 8, 0.26));
                break;
            default:
                raw.push(1);
            }
        }

        // Round off corners. Polygons need real smoothing; the cookies and
        // circles are already smooth, so a narrow window leaves them alone.
        const isPolygon = shape >= MaterialShape.Triangle && shape <= MaterialShape.Gem;
        if (isPolygon) {
            const window = Math.round(n / 24);
            for (let pass = 0; pass < 2; pass++) {
                const src = raw.slice();
                for (let i = 0; i < n; i++) {
                    let sum = 0;
                    for (let j = -window; j <= window; j++)
                        sum += src[(i + j + n) % n];
                    raw[i] = sum / (window * 2 + 1);
                }
            }
        }

        // Normalise so every shape fills the same bounding box
        const max = Math.max(...raw);
        return raw.map(r => r / max);
    }

    onShapeChanged: {
        fromRadii = toRadii;
        toRadii = radiiFor(shape);
        morph = 0;
        morphAnim.restart();
    }

    Anim {
        id: morphAnim

        target: root
        property: "morph"
        to: 1
        type: Anim.DefaultSpatial
    }

    ShapePath {
        strokeWidth: 0
        strokeColor: "transparent"
        fillColor: root.color

        PathPolyline {
            path: {
                const from = root.fromRadii;
                const to = root.toRadii;
                const t = root.morph;
                const n = root.samples;
                // Derived from implicitSize rather than width/height: Shape
                // feeds its content bounds back into its implicit size, and
                // reading width here closes that loop.
                const cx = root.implicitSize / 2;
                const cy = cx;
                const scale = cx;

                const points = [];
                for (let i = 0; i < n; i++) {
                    const a = (i / n) * Math.PI * 2;
                    const r = (from[i] + (to[i] - from[i]) * t) * scale;
                    points.push(Qt.point(cx + Math.cos(a) * r, cy + Math.sin(a) * r));
                }
                points.push(points[0]);
                return points;
            }
        }

        Behavior on fillColor {
            CAnim {}
        }
    }
}
