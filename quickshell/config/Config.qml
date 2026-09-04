//
// User-facing knobs. Everything you'd actually want to tweak lives here; the
// Material tokens in Appearance.qml stay untouched.
//
pragma Singleton

import QtQuick
import Quickshell

Singleton {
    readonly property BorderConfig border: BorderConfig {}
    readonly property BarConfig bar: BarConfig {}
    readonly property GeneralConfig general: GeneralConfig {}
    readonly property WallpaperConfig wallpapers: WallpaperConfig {}

    component GeneralConfig: QtObject {
        readonly property bool useTwelveHourClock: false
        // Run when the OS icon is clicked
        readonly property list<string> launcherCommand: ["rofi", "-show", "drun"]
    }

    component WallpaperConfig: QtObject {
        // Scanned one level deep for anything `file` calls an image
        readonly property string directory: `${Quickshell.env("HOME")}/Pictures/wallpapers`

        // The bottom-edge strip that opens the picker. Narrow and centred: it is
        // masked into the shell's input region, so every pixel of it is a pixel
        // the desktop below stops receiving clicks on.
        readonly property int hotZoneWidth: 120
        // Long enough that crossing the bottom edge on the way somewhere else
        // doesn't open it
        readonly property int dwell: 250
        // Grace before closing once the pointer leaves both the zone and the
        // panel. Generous because it is also the budget for the handoff between
        // them, and losing that race shuts the panel in your face.
        readonly property int closeDelay: 1200

        // A flick moves the selection several times on the way past, and each
        // preview is a real matugen run
        readonly property int previewDebounce: 150

        readonly property int itemWidth: 200
        readonly property int maxShown: 7
    }

    component BorderConfig: QtObject {
        readonly property int thickness: 10
        readonly property int rounding: 25
    }

    component BarConfig: QtObject {
        // Bar entries, top to bottom. "spacer" pushes everything after it down.
        readonly property list<string> entries: ["logo", "workspaces", "spacer", "tray", "statusIcons", "clock", "themeMode", "power"]

        readonly property WorkspacesConfig workspaces: WorkspacesConfig {}
        readonly property ClockConfig clock: ClockConfig {}
        readonly property TrayConfig tray: TrayConfig {}
        readonly property StatusIconsConfig statusIcons: StatusIconsConfig {}
    }

    component WorkspacesConfig: QtObject {
        readonly property int shown: 5
        readonly property bool activeIndicator: true
        readonly property bool occupiedBg: false
        // "shapes" for the morphing Material shapes, "text" for workspace numbers,
        // "icons" for a per-workspace Material Symbols glyph
        readonly property string displayType: "icons"
        // Glyph per workspace, indexed by workspace number. Any workspace past
        // the end of the list (or with an empty entry) falls back to defaultIcon.
        readonly property list<string> icons: ["public", "terminal", "forum", "music_note", "apps"]
        readonly property string defaultIcon: "circle"
        // Optional per-workspace icon colour, indexed like `icons`. An entry
        // overrides the dim occupied/empty colour so that glyph stays legible.
        // The focused workspace always uses m3onPrimary, since it sits on the
        // primary-coloured pill and a fixed colour would lose contrast there.
        //
        // Either a literal "#rrggbb" or the name of a role on the palette. Name
        // a role: a literal is one mode's colour frozen in place, and the
        // #ffffff that used to sit here dropped to 1.05:1 against the light
        // surface - the glyph was there, just invisible.
        readonly property list<string> iconColours: ["m3onSurface", "m3onSurface", "m3onSurface", "m3onSurface", "m3onSurface"]
        readonly property bool perMonitorWorkspaces: true
    }

    component ClockConfig: QtObject {
        readonly property bool background: true
        readonly property bool showIcon: false
        readonly property bool showDate: true
    }

    component TrayConfig: QtObject {
        readonly property bool background: true
        readonly property list<string> hiddenIcons: []
    }

    component StatusIconsConfig: QtObject {
        readonly property list<string> entries: ["memory", "audio", "network", "bluetooth", "battery"]
    }
}
