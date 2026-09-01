//
// The shell's colour API.
//
// Wraps the matugen-generated Scheme.qml and adds the bits the generated file
// can't know about: whether we're on a light or dark scheme, and the M3 surface
// "layer" helper used to tint containers when transparency is enabled.
//
pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.config

Singleton {
    id: root

    readonly property Scheme palette: Scheme {}
    readonly property TPalette tPalette: TPalette {}

    // Matugen doesn't record which mode it generated, so infer it. Every scheme
    // has a surface far from mid-grey, so this is unambiguous in practice.
    readonly property bool light: getLuminance(palette.m3surface) > 0.5

    function getLuminance(c: color): real {
        if (c.r === 0 && c.g === 0 && c.b === 0)
            return 0;
        return Math.sqrt(0.299 * c.r ** 2 + 0.587 * c.g ** 2 + 0.114 * c.b ** 2);
    }

    // Brightens (dark scheme) or darkens (light scheme) a colour so that a
    // container still reads as raised once the surface behind it goes translucent.
    function alterColour(c: color, a: real, depth: int): color {
        const luminance = getLuminance(c);
        if (luminance === 0)
            return Qt.rgba(c.r, c.g, c.b, a);

        const offset = (!light || depth === 1 ? 1 : -depth / 2) * (light ? 0.2 : 0.3) * (1 - Appearance.transparency.base);
        const scale = (luminance + offset) / luminance;

        return Qt.rgba(Math.min(1, c.r * scale), Math.min(1, c.g * scale), Math.min(1, c.b * scale), a);
    }

    function layer(c: color, depth: int): color {
        if (!Appearance.transparency.enabled)
            return c;
        return depth === 0 ? Qt.alpha(c, Appearance.transparency.base) : alterColour(c, Appearance.transparency.layers, depth);
    }

    // Resolves a colour written in the config: either a literal "#rrggbb", or
    // the name of a role on the palette. Naming a role is what lets a config
    // entry follow the theme - a literal is one mode's colour frozen in place,
    // and #ffffff is invisible the moment the surface goes light.
    function role(name: string): color {
        if (name.startsWith("#"))
            return name;
        // qmllint disable missing-property
        return palette[name] ?? palette.m3onSurface;
        // qmllint enable missing-property
    }

    // A readable foreground for an arbitrary background, keeping its hue.
    function on(c: color): color {
        if (c.hslLightness < 0.5)
            return Qt.hsla(c.hslHue, c.hslSaturation, 0.9, 1);
        return Qt.hsla(c.hslHue, c.hslSaturation, 0.1, 1);
    }

    // Transparency-aware variants of the surfaces widgets actually sit on.
    component TPalette: QtObject {
        readonly property color m3surface: root.layer(root.palette.m3surface, 0)
        readonly property color m3surfaceContainer: root.layer(root.palette.m3surfaceContainer, 1)
        readonly property color m3surfaceContainerHigh: root.layer(root.palette.m3surfaceContainerHigh, 2)
        readonly property color m3surfaceContainerHighest: root.layer(root.palette.m3surfaceContainerHighest, 3)
    }
}
