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
// The two can fall out of step, though, because either half can be moved on its
// own, so each direction gets brought back to the other below.
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

    // Bring the portal key and the GTK3 theme to the mode the palette is in,
    // without re-running matugen.
    //
    // `matugen image <wallpaper>` run by hand does exactly this to us: its
    // --mode defaults to dark, so it rewrites the palette and leaves the other
    // two layers behind. The desktop is then split - a dark bar, a still-light
    // Firefox - and the toggle's first click goes the wrong way, because the
    // two halves disagree about which mode it is leaving. The palette is what
    // you can see, so it wins and the other layers follow it.
    function syncToPalette(): void {
        if (busy || Colours.light === light)
            return;

        light = Colours.light;
        applyProc.command = [root.script, "apply", light ? "light" : "dark"];
        applyProc.running = true;
    }

    Component.onCompleted: light = Colours.light

    // A matugen run rewrites Scheme.qml, which reloads the config and builds a
    // fresh singleton, so the palette moving is usually *not* something this
    // instance lives to see a signal for - the startup read below is where that
    // case gets caught. This covers the one where the reload doesn't happen.
    Connections {
        target: Colours

        function onLightChanged(): void {
            root.syncToPalette();
        }
    }

    Process {
        id: readProc

        running: true
        command: [root.script, "status"]
        stdout: StdioCollector {
            // Never over a switch in flight. This process is also started at
            // construction, and its answer - taken before the script has
            // reached its gsettings writes - otherwise lands on top of the
            // optimistic value and drags the icon back to the old mode.
            onStreamFinished: {
                if (root.busy)
                    return;

                root.light = text.trim() === "light";
                // Running at construction is what makes this the reconcile
                // point after a config reload: if the palette we just came up
                // on disagrees with the key, something re-themed us behind the
                // portal's back.
                root.syncToPalette();
            }
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

    Process {
        id: applyProc
    }

    // Catches the key being changed by anything other than us
    Process {
        running: true
        command: ["gsettings", "monitor", "org.gnome.desktop.interface", "color-scheme"]
        stdout: SplitParser {
            onRead: line => {
                if (root.busy)
                    return;

                const wanted = line.includes("prefer-light");
                // Our own writes come back through here too; they already agree
                if (wanted === root.light)
                    return;

                root.light = wanted;
                // Changed by hand, so the palette is the half left behind this
                // time and needs the full re-theme rather than `apply`
                if (Colours.light !== wanted)
                    root.setMode(wanted ? "light" : "dark");
            }
        }
    }
}
