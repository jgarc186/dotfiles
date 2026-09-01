pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Bluetooth

Singleton {
    id: root

    // Quickshell's Bluetooth types aren't exposed declaratively, so these stay
    // untyped and the tooling can't resolve them either.
    // qmllint disable unresolved-type
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool enabled: adapter?.enabled ?? false
    readonly property bool discovering: adapter?.discovering ?? false

    readonly property var devices: Bluetooth.devices?.values ?? []
    readonly property var connected: devices.filter(d => d.connected)
    // qmllint enable unresolved-type
}
