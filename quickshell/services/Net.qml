//
// Network state via nmcli.
//
// NetworkManager's DBus interface isn't exposed by Quickshell, so we shell out.
// `nmcli monitor` streams change events, which we use to re-run the two cheap
// queries below - no polling.
//
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // "wifi" | "ethernet" | "" (disconnected)
    property string type: ""
    property string ssid: ""
    property int strength: 0

    readonly property bool connected: type !== ""
    readonly property bool ethernet: type === "ethernet"

    function refresh(): void {
        deviceProc.running = true;
        wifiProc.running = true;
    }

    Component.onCompleted: refresh()

    // Which device type is actually carrying traffic
    Process {
        id: deviceProc

        command: ["nmcli", "-t", "-f", "TYPE,STATE", "device", "status"]
        stdout: StdioCollector {
            onStreamFinished: {
                for (const line of text.trim().split("\n")) {
                    const [type, state] = line.split(":");
                    if (state !== "connected")
                        continue;
                    if (type === "ethernet") {
                        root.type = "ethernet";
                        return;
                    }
                    if (type === "wifi") {
                        root.type = "wifi";
                        return;
                    }
                }
                root.type = "";
            }
        }
    }

    // Signal strength of the AP we're on
    Process {
        id: wifiProc

        command: ["nmcli", "-t", "-f", "IN-USE,SIGNAL,SSID", "device", "wifi"]
        stdout: StdioCollector {
            onStreamFinished: {
                for (const line of text.trim().split("\n")) {
                    if (!line.startsWith("*"))
                        continue;
                    const parts = line.split(":");
                    root.strength = parseInt(parts[1]) || 0;
                    root.ssid = parts.slice(2).join(":");
                    return;
                }
                root.strength = 0;
                root.ssid = "";
            }
        }
    }

    Process {
        running: true
        command: ["nmcli", "monitor"]
        stdout: SplitParser {
            onRead: root.refresh()
        }
    }
}
