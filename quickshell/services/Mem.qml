//
// Memory usage, read from /proc/meminfo.
//
// procfs files report a size of 0, but FileView reads them correctly and
// reload() re-reads rather than serving a cache, so a timer is all this needs.
// inotify doesn't fire on procfs, so watchChanges would never trigger.
//
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // Kibibytes, as /proc/meminfo reports them
    property int total: 0
    // MemAvailable, not MemFree: the kernel's own estimate of what a new
    // allocation could claim, which counts reclaimable cache as free
    property int available: 0

    readonly property int used: Math.max(0, total - available)
    readonly property real usage: total > 0 ? used / total : 0

    readonly property string summary: total > 0 ? `${formatSize(used)} / ${formatSize(total)} · ${Math.round(usage * 100)}%` : "Memory"

    // Ref count of widgets currently showing the numbers. Polling every second
    // for a tooltip nobody is looking at is waste, but a tooltip that sits
    // frozen while you hover it looks broken.
    property int watchers: 0

    function watch(): void {
        watchers++;
    }

    function unwatch(): void {
        watchers = Math.max(0, watchers - 1);
    }

    function formatSize(kb: int): string {
        return `${(kb / 1048576).toFixed(1)} GiB`;
    }

    Timer {
        interval: root.watchers > 0 ? 1000 : 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: view.reload()
    }

    FileView {
        id: view

        path: "/proc/meminfo"
        onLoaded: {
            const contents = text();
            const total = contents.match(/^MemTotal:\s+(\d+)/m);
            const available = contents.match(/^MemAvailable:\s+(\d+)/m);

            if (total)
                root.total = parseInt(total[1]);
            if (available)
                root.available = parseInt(available[1]);
        }
    }
}
