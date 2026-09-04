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

    // The committed scheme: matugen's generated Scheme.qml, which is an instance
    // of M3Palette so that `preview` below can be the same shape.
    readonly property M3Palette current: Scheme {}

    // Filled by load() from a `matugen --dry-run`, so the wallpaper picker can
    // retint the whole shell without writing a thing. Nothing else should touch it.
    readonly property M3Palette preview: M3Palette {}

    property bool showPreview: false

    readonly property M3Palette palette: showPreview ? preview : current
    readonly property TPalette tPalette: TPalette {}

    // What the shell is painted in - the preview while one is up.
    readonly property bool light: modeOf(palette)

    // What is actually on disk, preview or not. Theme reads this rather than
    // `light`: it drives `theme-mode apply`, which moves the portal key and the
    // GTK3 theme, and scrolling the picker past a light wallpaper in dark mode
    // would otherwise flip Firefox and every GTK3 app to match a preview that
    // was never committed. The failure is invisible from inside the shell.
    readonly property bool currentLight: modeOf(current)

    // The template records the mode it generated in. Fall back to inferring it
    // from the surface for a scheme written before it did - every scheme has a
    // surface far from mid-grey, so that stays unambiguous in practice.
    function modeOf(p: M3Palette): bool {
        return p.mode ? p.mode === "light" : getLuminance(p.m3surface) > 0.5;
    }

    // Fills `preview` from the JSON `matugen ... --dry-run -j hex` writes.
    //
    // Two traps live in that dump. Its colour entries are keyed `color`, not
    // `hex` - the `.default.hex` the templates use is the *template engine's*
    // spelling and reads as undefined here. And the roles are snake_case, so the
    // names have to be converted.
    //
    // Walks the JSON rather than the palette's own properties: a plain object
    // enumerates predictably, where relying on a QObject to list its QML-declared
    // properties would put the whole mapping on undefined behaviour. The dump
    // carries every role we declare plus source_color, which converts to a name
    // no property has and is skipped by the undefined check.
    function load(data: string): void {
        const scheme = JSON.parse(data);
        const colours = scheme.colors ?? {};

        for (const role in colours) {
            const prop = "m3" + role.replace(/_(.)/g, (_, c) => c.toUpperCase());
            // An undeclared role reads back undefined; a declared one is a colour
            if (preview[prop] === undefined)
                continue;

            const colour = colours[role]?.default?.color;
            if (colour)
                preview[prop] = colour;
        }

        preview.mode = scheme.mode ?? (scheme.is_dark_mode ? "dark" : "light");
    }

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
