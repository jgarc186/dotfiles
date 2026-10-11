//
// Free space on the filesystem the desktop lives on, read from `df`.
//
// Unlike Mem there is no procfs file to read: these numbers come from statvfs,
// which only a process can ask for, so this shells out to df and parses the one
// line it prints. Disk space moves far slower than memory does, hence the much
// lazier idle interval.
//
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

Singleton {
    id: root

    // Kibibytes, as `df -k` reports them. Real rather than int: a 4 TiB drive
    // is 4.3e9 KiB, which overflows QML's 32-bit int and comes back negative.
    property real total: 0
    property real used: 0
    // What a normal process could actually claim, which is not total - used:
    // ext4 keeps a reserve (5% by default) only root may touch, so the three
    // figures deliberately don't add up.
    property real available: 0

    readonly property real usage: total > 0 ? used / total : 0

    // Multi-line on purpose: the bubble is the only place these numbers appear,
    // and used/free/total on one line runs most of the way across the screen.
    readonly property string summary: total > 0 ? `Disk · ${Math.round(usage * 100)}%\nUsed ${formatSize(used)}\nFree ${formatSize(available)}\nTotal ${formatSize(total)}` : "Disk"

    // Ref count of widgets currently showing the numbers, as in Mem: a tooltip
    // nobody is looking at doesn't need the faster poll.
    property int watchers: 0

    function watch(): void {
        watchers++;
    }

    function unwatch(): void {
        watchers = Math.max(0, watchers - 1);
    }

    function formatSize(kb: real): string {
        const gib = kb / 1048576;
        return gib >= 1024 ? `${(gib / 1024).toFixed(2)} TiB` : `${gib.toFixed(1)} GiB`;
    }

    Timer {
        interval: root.watchers > 0 ? 5000 : 60000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: proc.running = true
    }

    Process {
        id: proc

        // -P for POSIX output: without it df breaks a long device name onto its
        // own line and the figures end up on line 3 rather than line 2.
        command: ["df", "-kP", Config.bar.statusIcons.diskPath]
        stdout: StdioCollector {
            onStreamFinished: {
                const line = text.trim().split("\n")[1];
                if (!line)
                    return;

                const fields = line.trim().split(/\s+/);
                if (fields.length < 4)
                    return;

                root.total = parseInt(fields[1]);
                root.used = parseInt(fields[2]);
                root.available = parseInt(fields[3]);
            }
        }
    }
}
