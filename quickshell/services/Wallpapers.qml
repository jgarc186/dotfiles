//
// The wallpaper list, the one in use, and the live palette preview.
//
// Modelled on caelestia-dots/shell's services/Wallpapers.qml, minus the pieces
// that need its C++ plugin: no FileSystemModel for the listing, no fuzzy
// searcher, and the preview palette comes straight from matugen rather than
// from a helper binary.
//
// Applying goes through Theme rather than running matugen here, so that a
// wallpaper change and a light/dark switch share the one `busy` guard - they
// both end in a matugen run over the same set of template outputs.
//
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

Singleton {
    id: root

    // Absolute paths, sorted. Empty until the listing lands.
    property list<string> list: []

    // The wallpaper the palette on disk was generated from.
    property string current: ""

    // The stored source-colour index, so a preview reproduces the palette an
    // apply would actually produce rather than always previewing candidate 0.
    property int sourceIndex: 0

    function basename(path: string): string {
        return path.slice(path.lastIndexOf("/") + 1);
    }

    // A path is not a URL. Qt percent-decodes what it is handed, so a file whose
    // *name* contains a percent escape - there is one in this directory, an
    // "%C3%AB" that came down with the download - resolves to a decoded name that
    // doesn't exist on disk, and the thumbnail silently fails to open. Encoding
    // per segment keeps the separators while escaping the percent signs and
    // spaces inside each one.
    function fileUrl(path: string): string {
        return "file://" + path.split("/").map(encodeURIComponent).join("/");
    }

    // Retint the shell from `path` without writing anything to disk. Debounced:
    // a flick through the carousel changes the selection several times on the
    // way past, and each run costs real CPU (~0.2s for a 1MB image, ~2.5s for a
    // 10MB one).
    function preview(path: string): void {
        if (!path || path === previewPath)
            return;

        // The committed palette already *is* this wallpaper's palette, so
        // generating it again would spend a matugen run arriving back at what is
        // on screen. Landing here on open is the common case, since the carousel
        // starts on the wallpaper in use.
        if (path === current) {
            stopPreview();
            return;
        }

        previewPath = path;
        previewTimer.restart();
    }

    function stopPreview(): void {
        previewTimer.stop();
        previewProc.running = false;
        previewPath = "";
        Colours.showPreview = false;
    }

    function setWallpaper(path: string): void {
        // Optimistically, like Theme moves its icon before the script returns:
        // the ring should land on the item that was clicked, not a matugen run
        // later. The FileView below corrects it if the run fails.
        current = path;
        stopPreview();
        Theme.setWallpaper(path);
    }

    property string previewPath: ""

    Timer {
        id: previewTimer

        interval: Config.wallpapers.previewDebounce
        onTriggered: {
            // Dropping `running` first cancels a run still working on the
            // wallpaper before this one, whose colours would otherwise land on
            // top of these
            previewProc.running = false;
            previewProc.command = ["matugen", "image", root.previewPath, "--mode", Colours.currentLight ? "light" : "dark", "--source-color-index", String(root.sourceIndex), "--dry-run", "-j", "hex"];
            previewProc.running = true;
        }
    }

    Process {
        id: previewProc

        stdout: StdioCollector {
            onStreamFinished: {
                // Out-of-bounds indices and unreadable images exit non-zero with
                // nothing on stdout; leave the committed palette alone
                if (!text.startsWith("{"))
                    return;

                Colours.load(text);
                Colours.showPreview = true;
            }
        }
    }

    // Deliberately not Qt.labs.folderlistmodel with extension nameFilters: this
    // directory holds an HTML document with no extension and a JPEG with no
    // extension, so filtering on the name gets both wrong in opposite
    // directions. `file` reads what each one actually is.
    //
    // Three things here are load-bearing, and each returned an empty list or a
    // list that matched nothing when it was missing:
    //
    //   realpath   - the default directory is a symlink into the dotfiles repo
    //                (install makes it), and theme-mode writes the wallpaper it
    //                themed from through realpath too. Resolving here is what
    //                makes `current` comparable to what comes out of the list at
    //                all; without it the ring never lands on anything.
    //   find -L    - find does not follow a symlinked starting directory, so
    //                `-type f` matches nothing through it.
    //   awk on $2  - `file -N -F` still writes a space after the separator, so
    //                matching the mime against the whole line is the only thing
    //                that works, and matching a field is what stops a directory
    //                named "image" from passing everything.
    Process {
        id: listProc

        running: true
        command: ["sh", "-c", `dir=$(realpath "$1") || exit 0; find -L "$dir" -maxdepth 1 -type f -exec file --mime-type -N -F '\t' {} + | awk -F'\t' 'tolower($2) ~ /image\\//{print $1}' | sort`, "sh", Config.wallpapers.directory]
        stdout: StdioCollector {
            onStreamFinished: root.list = text.trim().split("\n").filter(l => l.length > 0)
        }
    }

    // The generated hyprland colours carry the wallpaper matugen last ran on as
    // line 1. Reading it back is what theme-mode's current_wallpaper() does, so
    // there's no second record to fall out of step - and watching it means a
    // `matugen image` run by hand moves the highlight too.
    FileView {
        path: `${Quickshell.env("HOME")}/.config/hypr/colors.conf`
        watchChanges: true
        printErrors: false

        onFileChanged: reload()
        onLoaded: {
            const match = /^\$image = (.+)$/m.exec(text());
            if (match)
                root.current = match[1].trim();

            // Re-read alongside the palette: an apply may have moved it
            indexProc.running = true;
        }
    }

    Process {
        id: indexProc

        running: true
        command: [Theme.script, "index"]
        stdout: StdioCollector {
            onStreamFinished: root.sourceIndex = parseInt(text.trim()) || 0
        }
    }
}
