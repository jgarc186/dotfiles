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

    // Bar tooltip: the text to show, and the y centre (in window coordinates)
    // of the widget that asked for it. The owner is tracked so that a pointer
    // moving straight from one widget to the next can't have the first one's
    // exit blank the second one's tooltip.
    property Item tooltipOwner: null
    property string tooltipText: ""
    property real tooltipY: 0

    // Only one popout at a time
    onSessionChanged: if (session)
        network = false
    onNetworkChanged: if (network)
        session = false

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
