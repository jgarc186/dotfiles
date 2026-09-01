//
// Light/dark mode for the whole desktop.
//
// The switching itself lives in scripts/theme-mode, because it spans three
// unrelated layers (matugen, the portal's colour-scheme key, and the GTK3 theme
// name) and is just as useful from a keybind or a terminal as from the bar.
//
// What the bar shows comes from the portal key rather than from our own palette:
// it is what the *system* is set to, and reading it means an external change -
// gsettings run by hand, another tool flipping it - is reflected here too.
//
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.services

Singleton {
    id: root

    readonly property string script: `${Quickshell.env("HOME")}/.local/bin/theme-mode`

    // Seeded from the palette, because rewriting Scheme.qml is what makes
    // Quickshell reload the config, and that recreates this singleton
    // mid-switch: starting from a fixed default would blink the icon back to
    // the old mode until the status read landed.
    //
    // Seeded once rather than bound, so that a gsettings change made outside
    // this shell still wins: a standing binding on Colours would keep pulling
    // the value back to whatever the palette says.
    property bool light: false
    // matugen rewrites every template on the way through, so a second run
    // started over the first interleaves their writes
    property bool busy: false

    function toggle(): void {
        setMode(light ? "dark" : "light");
    }

    function setMode(mode: string): void {
        if (busy)
            return;

        busy = true;
        // Move the icon now instead of at the end of the run. The script takes
        // well under a second, but waiting for it means the one control that
        // should feel immediate is the last thing on screen to move. If the run
        // fails, the read below puts it back.
        light = mode === "light";

        setProc.command = [root.script, mode];
        setProc.running = true;
    }

    Component.onCompleted: light = Colours.light

    Process {
        id: readProc

        running: true
        command: [root.script, "status"]
        stdout: StdioCollector {
            // Never over a switch in flight. This process is also started at
            // construction, and its answer - taken before the script has
            // reached its gsettings writes - otherwise lands on top of the
            // optimistic value and drags the icon back to the old mode.
            onStreamFinished: if (!root.busy)
                root.light = text.trim() === "light"
        }
    }

    // The linter can't compile an `exited` handler: the signal's exitStatus
    // parameter is a QProcess::ExitStatus, which Quickshell doesn't register as
    // a QML type. The handler itself runs fine.
    // qmllint disable signal-handler-parameters
    Process {
        id: setProc

        onExited: {
            root.busy = false;
            readProc.running = true;
        }
    }
    // qmllint enable signal-handler-parameters

    // Catches the key being changed by anything other than us
    Process {
        running: true
        command: ["gsettings", "monitor", "org.gnome.desktop.interface", "color-scheme"]
        stdout: SplitParser {
            onRead: line => root.light = line.includes("prefer-light")
        }
    }
}
