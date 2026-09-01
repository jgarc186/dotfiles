//
// Transient UI state that outlives the widget that toggled it.
//
pragma Singleton

import QtQuick
import Quickshell

Singleton {
    property bool session: false
}
