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

Singleton {
    id: root

    readonly property string script: `${Quickshell.env("HOME")}/.local/bin/theme-mode`

    // 'default' is the value the key ships with, and on this setup the scheme
    // matugen generated for it is the dark one
    property bool light: false
    // matugen takes a moment to regenerate every template, and starting a
    // second run over the top of the first interleaves their writes
    property bool busy: false

    function toggle(): void {
        setMode(light ? "dark" : "light");
    }

    function setMode(mode: string): void {
        if (busy)
            return;

        busy = true;
        setProc.command = [root.script, mode];
        setProc.running = true;
    }

    Process {
        id: readProc

        running: true
        command: [root.script, "status"]
        stdout: StdioCollector {
            onStreamFinished: root.light = text.trim() === "light"
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
