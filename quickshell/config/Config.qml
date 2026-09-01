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

    component GeneralConfig: QtObject {
        readonly property bool useTwelveHourClock: false
        // Run when the OS icon is clicked
        readonly property list<string> launcherCommand: ["rofi", "-show", "drun"]
    }

    component BorderConfig: QtObject {
        readonly property int thickness: 10
        readonly property int rounding: 25
    }

    component BarConfig: QtObject {
        // Bar entries, top to bottom. "spacer" pushes everything after it down.
        readonly property list<string> entries: ["logo", "workspaces", "spacer", "tray", "statusIcons", "clock", "power"]

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
        readonly property list<string> iconColours: ["", "", "", "#ffffff", ""]
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
        readonly property list<string> entries: ["audio", "network", "bluetooth", "battery"]
    }
}
