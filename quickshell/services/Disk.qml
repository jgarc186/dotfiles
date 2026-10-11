//
// Free space on the filesystem the desktop lives on, read from `df`.
//
// Unlike Mem there is no procfs file to read: these numbers come from statvfs,
// which only a process can ask for, so this shells out to df and parses the one
// line it prints. Disk space moves far slower than memory does, hence the much
// lazier idle interval.
//
// Also breaks the used space down by kind of file for the storage popout, via
// scripts/disk-usage. That is a walk of the whole home directory - well over a
// million files, tens of seconds - so it runs only when something asks for it,
// in the background, and its result is kept and reused until it is
// Config.bar.statusIcons.diskScanMaxAge old.
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

    // Name and glyph per category key the scan script prints. "system" is not
    // one of the script's: it is whatever df counts as used that the scan
    // didn't reach, i.e. everything outside $HOME and /var/cache.
    readonly property var kinds: ({
            videos: {
                label: "Videos",
                icon: "movie"
            },
            photos: {
                label: "Photos",
                icon: "photo_library"
            },
            audio: {
                label: "Audio",
                icon: "music_note"
            },
            documents: {
                label: "Documents",
                icon: "description"
            },
            archives: {
                label: "Archives",
                icon: "folder_zip"
            },
            images: {
                label: "Disk images & VMs",
                icon: "deployed_code"
            },
            dev: {
                label: "Code & dev",
                icon: "code"
            },
            cache: {
                label: "Caches",
                icon: "cached"
            },
            trash: {
                label: "Trash",
                icon: "delete"
            },
            other: {
                label: "Other files",
                icon: "draft"
            },
            system: {
                label: "System & apps",
                icon: "settings"
            }
        })

    // KiB per category key, and their total, from the last finished scan
    property var scanned: ({})
    property real scannedTotal: 0
    // [{ path, size }] in KiB, biggest first
    property var largest: []
    // Date.now() of the last finished scan, 0 before the first
    property real scannedAt: 0
    readonly property bool scanning: scanProc.running

    // [{ key, label, icon, size }] in KiB, biggest first, with the unscanned
    // remainder as "system". Rebuilt when df moves too, so that remainder
    // tracks the live figure between scans.
    readonly property var breakdown: {
        if (scannedAt === 0)
            return [];

        const sizes = Object.assign({}, scanned);
        // Clamped: files written since the scan can push it past df's figure
        sizes.system = Math.max(0, used - scannedTotal);

        return Object.keys(sizes).filter(k => sizes[k] > 0).map(k => ({
                    key: k,
                    label: kinds[k]?.label ?? k,
                    icon: kinds[k]?.icon ?? "draft",
                    size: sizes[k]
                })).sort((a, b) => b.size - a.size);
    }

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

    // Walks the disk unless the last result is still fresh. `force` skips the
    // freshness check, for the popout's refresh button.
    function scan(force: bool): void {
        if (scanProc.running)
            return;
        if (!force && scannedAt > 0 && Date.now() - scannedAt < Config.bar.statusIcons.diskScanMaxAge)
            return;
        scanProc.running = true;
    }

    function formatSize(kb: real): string {
        const gib = kb / 1048576;
        if (gib >= 1024)
            return `${(gib / 1024).toFixed(2)} TiB`;
        // The breakdown has categories far below a gibibyte, which would all
        // read "0.0 GiB" - or, a trash with a couple of files in it, "0 MiB"
        if (kb < 1024)
            return `${Math.round(kb)} KiB`;
        if (gib < 1)
            return `${Math.round(kb / 1024)} MiB`;
        return `${gib.toFixed(1)} GiB`;
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

    Process {
        id: scanProc

        command: [Quickshell.shellPath("scripts/disk-usage"), "5"]
        stdout: StdioCollector {
            onStreamFinished: {
                const scanned = {};
                const largest = [];
                let total = 0;

                for (const line of text.split("\n")) {
                    const fields = line.split("\t");
                    // The script prints bytes; everything here is KiB, like df
                    if (fields[0] === "cat" && fields.length === 3)
                        scanned[fields[1]] = parseFloat(fields[2]) / 1024;
                    else if (fields[0] === "scanned" && fields.length === 2)
                        total = parseFloat(fields[1]) / 1024;
                    else if (fields[0] === "big" && fields.length >= 3)
                        largest.push({
                            size: parseFloat(fields[1]) / 1024,
                            // A tab in a file name would split it; put it back
                            path: fields.slice(2).join("\t")
                        });
                }

                // A scan that died before printing anything isn't "nothing
                // used", so keep the previous result rather than blanking it
                if (total <= 0)
                    return;

                root.scanned = scanned;
                root.scannedTotal = total;
                root.largest = largest;
                root.scannedAt = Date.now();
            }
        }
    }
}
