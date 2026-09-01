//
// Network state and control via nmcli.
//
// NetworkManager's DBus interface isn't exposed by Quickshell, so we shell out.
// `nmcli monitor` streams change events, which we use to re-run the cheap
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

    // Wireless interface, needed to disconnect
    property string device: ""
    property bool wifiEnabled: false

    // Visible access points, strongest first, active one pinned to the top.
    // Each entry: { ssid, strength, secured, active, known }
    property var accessPoints: []
    // Names of saved 802-11-wireless profiles
    property var savedNetworks: []

    // In-flight state for the popout
    property bool scanning: false
    property bool connecting: false
    property string pendingSsid: ""
    property string lastError: ""

    readonly property bool connected: type !== ""
    readonly property bool ethernet: type === "ethernet"

    // A saved profile means we can connect without asking for a password.
    // nmcli names a wifi profile after its SSID unless it was renamed by hand.
    readonly property var networks: accessPoints.map(ap => ({
                ssid: ap.ssid,
                strength: ap.strength,
                secured: ap.secured,
                active: ap.active,
                known: root.savedNetworks.includes(ap.ssid)
            }))

    function refresh(): void {
        deviceProc.running = true;
        listProc.running = true;
        savedProc.running = true;
        radioProc.running = true;
    }

    function scan(): void {
        if (scanning)
            return;
        scanning = true;
        scanProc.running = true;
    }

    function connectTo(ssid: string, password: string): void {
        if (connecting)
            return;

        lastError = "";
        pendingSsid = ssid;
        connecting = true;

        connectProc.command = password ? ["nmcli", "device", "wifi", "connect", ssid, "password", password] : ["nmcli", "device", "wifi", "connect", ssid];
        connectProc.running = true;
    }

    function disconnect(): void {
        if (device)
            disconnectProc.running = true;
    }

    function setWifiEnabled(enabled: bool): void {
        radioSetProc.command = ["nmcli", "radio", "wifi", enabled ? "on" : "off"];
        radioSetProc.running = true;
    }

    // nmcli -t escapes colons inside values as "\:", so splitting on ":" alone
    // mangles any SSID (or MAC) containing one.
    function splitFields(line: string): var {
        const fields = [];
        let field = "";

        for (let i = 0; i < line.length; i++) {
            const c = line[i];
            if (c === "\\" && i + 1 < line.length)
                field += line[++i];
            else if (c === ":") {
                fields.push(field);
                field = "";
            } else
                field += c;
        }

        fields.push(field);
        return fields;
    }

    Component.onCompleted: refresh()

    // Which device type is actually carrying traffic
    Process {
        id: deviceProc

        command: ["nmcli", "-t", "-f", "DEVICE,TYPE,STATE", "device", "status"]
        stdout: StdioCollector {
            onStreamFinished: {
                let type = "";
                let device = "";

                for (const line of text.trim().split("\n")) {
                    const [name, kind, state] = root.splitFields(line);

                    // Remember the wifi interface whether or not it's up, so
                    // disconnect still has something to act on
                    if (kind === "wifi" && !device)
                        device = name;

                    if (state !== "connected")
                        continue;
                    if (kind === "ethernet")
                        type = "ethernet";
                    else if (kind === "wifi" && type !== "ethernet")
                        type = "wifi";
                }

                root.type = type;
                root.device = device;
            }
        }
    }

    // Visible APs, plus the signal strength of the one we're on
    Process {
        id: listProc

        command: ["nmcli", "-t", "-f", "IN-USE,SIGNAL,SSID,SECURITY", "device", "wifi", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                const byName = {};
                const aps = [];

                for (const line of text.trim().split("\n")) {
                    if (!line)
                        continue;

                    const [inUse, signal, ssid, security] = root.splitFields(line);
                    if (!ssid)
                        continue; // hidden network

                    const strength = parseInt(signal) || 0;
                    const active = inUse === "*";

                    // One SSID can be several APs; collapse them into the
                    // strongest, which is the one nmcli would pick anyway
                    const existing = byName[ssid];
                    if (existing) {
                        existing.strength = Math.max(existing.strength, strength);
                        existing.active = existing.active || active;
                        continue;
                    }

                    const ap = {
                        ssid: ssid,
                        strength: strength,
                        secured: security !== "",
                        active: active
                    };
                    byName[ssid] = ap;
                    aps.push(ap);
                }

                aps.sort((a, b) => (b.active - a.active) || (b.strength - a.strength));
                root.accessPoints = aps;

                const current = aps.find(ap => ap.active);
                root.ssid = current?.ssid ?? "";
                root.strength = current?.strength ?? 0;
            }
        }
    }

    Process {
        id: savedProc

        command: ["nmcli", "-t", "-f", "NAME,TYPE", "connection", "show"]
        stdout: StdioCollector {
            onStreamFinished: {
                const names = [];

                for (const line of text.trim().split("\n")) {
                    const [name, kind] = root.splitFields(line);
                    if (kind === "802-11-wireless" && !names.includes(name))
                        names.push(name);
                }

                root.savedNetworks = names;
            }
        }
    }

    Process {
        id: radioProc

        command: ["nmcli", "-t", "radio", "wifi"]
        stdout: StdioCollector {
            onStreamFinished: root.wifiEnabled = text.trim() === "enabled"
        }
    }

    // The linter can't compile an `exited` handler: the signal's exitStatus
    // parameter is a QProcess::ExitStatus, which Quickshell doesn't register as
    // a QML type. The handlers themselves run fine.
    // qmllint disable signal-handler-parameters
    Process {
        id: radioSetProc

        onExited: root.refresh()
    }

    // Results arrive via nmcli monitor, but refresh anyway in case the scan
    // turned up nothing new to report
    Process {
        id: scanProc

        command: ["nmcli", "device", "wifi", "rescan"]
        onExited: {
            root.scanning = false;
            listProc.running = true;
        }
    }

    Process {
        id: connectProc

        stderr: StdioCollector {
            id: connectError
        }

        onExited: exitCode => {
            root.lastError = exitCode === 0 ? "" : connectError.text.trim().replace(/^Error:\s*/, "") || "Connection failed";
            root.connecting = false;
            root.refresh();
        }
    }

    Process {
        id: disconnectProc

        command: ["nmcli", "device", "disconnect", root.device]
        onExited: root.refresh()
    }

    // qmllint enable signal-handler-parameters

    Process {
        running: true
        command: ["nmcli", "monitor"]
        stdout: SplitParser {
            onRead: root.refresh()
        }
    }
}
