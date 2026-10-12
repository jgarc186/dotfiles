//
// CPU temperature, read from the CPU's hwmon sensor.
//
// hwmon numbering is not stable across boots, so the sensor is found by its
// driver name once at startup: coretemp's package sensor on Intel, k10temp's
// Tctl on AMD, else the driver's first input. sysfs never fires inotify, so it
// is polled like Mem - and only while something is showing it.
//
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // Celsius; -1 until read, or on a machine with no known CPU sensor
    property real temperature: -1
    property string path: ""

    property int watchers: 0

    function watch(): void {
        watchers++;
    }

    function unwatch(): void {
        watchers = Math.max(0, watchers - 1);
    }

    Process {
        running: true
        command: ["sh", "-c", `
            for d in /sys/class/hwmon/hwmon*; do
                case "$(cat "$d/name" 2>/dev/null)" in
                coretemp | k10temp | zenpower | cpu_thermal) ;;
                *) continue ;;
                esac
                for l in "$d"/temp*_label; do
                    case "$(cat "$l" 2>/dev/null)" in
                    "Package id 0" | Tctl | Tdie)
                        echo "\${l%_label}_input"
                        exit
                        ;;
                    esac
                done
                echo "$d/temp1_input"
                exit
            done`]

        stdout: StdioCollector {
            onStreamFinished: root.path = text.trim()
        }
    }

    Timer {
        interval: 1000
        running: root.watchers > 0 && root.path !== ""
        repeat: true
        triggeredOnStart: true
        onTriggered: view.reload()
    }

    FileView {
        id: view

        path: root.path
        // Millidegrees
        onLoaded: {
            const milli = parseInt(text());
            root.temperature = isNaN(milli) ? -1 : milli / 1000;
        }
    }
}
