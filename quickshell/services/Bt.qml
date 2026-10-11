pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Bluetooth

Singleton {
    id: root

    // Quickshell's Bluetooth types aren't exposed declaratively, so these stay
    // untyped and the tooling can't resolve them either - which also means the
    // linter can't see that `devices` is an ObjectModel with a `values` list,
    // or that it is nullable before the adapter comes up.
    // qmllint disable unresolved-type missing-property redundant-optional-chaining
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool enabled: adapter?.enabled ?? false
    readonly property bool discovering: adapter?.discovering ?? false

    readonly property var devices: Bluetooth.devices?.values ?? []
    readonly property var connected: devices.filter(d => d.connected)
    // qmllint enable unresolved-type missing-property redundant-optional-chaining
}
