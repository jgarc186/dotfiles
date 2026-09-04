//
// Transient UI state that outlives the widget that toggled it.
//
pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    property bool session: false
    property bool network: false
    property bool audio: false
    property bool wallpapers: false

    // The y centre (in window coordinates) of the bar icon that opened a
    // popout, so the popout tracks the icon instead of the screen's middle -
    // those coincide on a small monitor and diverge badly on a large one.
    // ShellWindow clamps them to the frame.
    property real networkY: 0
    property real audioY: 0

    // Bar tooltip: the text to show, and the y centre (in window coordinates)
    // of the widget that asked for it. The owner is tracked so that a pointer
    // moving straight from one widget to the next can't have the first one's
    // exit blank the second one's tooltip.
    property Item tooltipOwner: null
    property string tooltipText: ""
    property real tooltipY: 0

    // Only one popout at a time. Each handler closes the others rather than a
    // shared "current popout" string, so a widget can keep binding to its own
    // flag (fill, ripple) without knowing the whole set.
    onSessionChanged: if (session) {
        network = false;
        audio = false;
        wallpapers = false;
    }
    onNetworkChanged: if (network) {
        session = false;
        audio = false;
        wallpapers = false;
    }
    onAudioChanged: if (audio) {
        session = false;
        network = false;
        wallpapers = false;
    }
    onWallpapersChanged: if (wallpapers) {
        session = false;
        network = false;
        audio = false;
    }

    function showTooltip(owner: Item, text: string, y: real): void {
        tooltipOwner = owner;
        tooltipText = text;
        tooltipY = y;
    }

    // Keeps a visible tooltip in sync with state that changed under it
    function updateTooltip(owner: Item, text: string): void {
        if (tooltipOwner === owner)
            tooltipText = text;
    }

    function hideTooltip(owner: Item): void {
        if (tooltipOwner !== owner)
            return;
        tooltipOwner = null;
        tooltipText = "";
    }
}
