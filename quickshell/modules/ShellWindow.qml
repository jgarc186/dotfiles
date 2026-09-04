//
// One per screen: draws the border frame, hosts the bar, and masks input.
//
// The window spans the whole screen (it has to, to draw the frame) and ignores
// exclusion zones - modules/border/Exclusions.qml reserves the space instead.
// The input mask is limited to the bar and any open popout, so the decorative
// frame doesn't swallow clicks meant for the desktop.
//
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import "bar"
import "border"
import "network"
import "session"
import "volume"
import "wallpapers"
import qs.components
import qs.config
import qs.services

StyledWindow {
    id: root

    required property int barWidth

    // A fullscreen window on this monitor hides the frame entirely
    readonly property bool fullscreen: {
        const mon = Hypr.monitorFor(screen);
        const toplevels = mon?.activeWorkspace?.toplevels?.values ?? [];
        return toplevels.some(t => (t.lastIpcObject?.fullscreen ?? 0) > 1);
    }

    name: "shell"

    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true

    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Top
    // The Wi-Fi popout has a password field, so it needs keys too
    WlrLayershell.keyboardFocus: ShellState.session || ShellState.network ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    mask: Region {
        item: bar

        Region {
            item: session
        }

        Region {
            item: network
        }

        Region {
            item: volume
        }

        // Both halves of the wallpaper picker have to be here, and this is the
        // only reason the bottom edge is clickable at all: everything outside the
        // mask passes straight through to the desktop, which is what the rest of
        // the decorative frame does.
        Region {
            item: wallpaperZone
        }

        Region {
            item: wallpapers
        }
    }

    Border {
        anchors.fill: parent

        borderLeft: bar.implicitWidth
        borderTop: root.fullscreen ? 0 : Config.border.thickness
        borderRight: root.fullscreen ? 0 : Config.border.thickness
        borderBottom: root.fullscreen ? 0 : Config.border.thickness
    }

    BarWrapper {
        id: bar

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left

        screen: root.screen
        contentWidth: root.barWidth
        fullscreen: root.fullscreen
    }

    // Session popout, anchored to the power button's end of the bar. Stays
    // loaded until it has faded out, so closing it animates too.
    Loader {
        id: session

        anchors.left: bar.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Config.border.thickness
        anchors.leftMargin: Appearance.spacing.small

        active: ShellState.session || opacity > 0
        opacity: ShellState.session ? 1 : 0
        scale: ShellState.session ? 1 : 0.85
        transformOrigin: Item.BottomLeft

        sourceComponent: Session {}

        Behavior on opacity {
            Anim {
                type: Anim.DefaultEffects
            }
        }

        Behavior on scale {
            Anim {
                type: Anim.FastSpatial
            }
        }
    }

    // Wi-Fi popout, pinned to the y of the bar icon that opened it rather than
    // to the screen's centre - the two happen to coincide on a laptop panel and
    // are far apart on a large monitor, which read as the popout drifting up.
    // The list is tall, so the position is clamped inside the frame; that also
    // keeps it on-screen when the icon sits near an edge.
    Loader {
        id: network

        anchors.left: bar.right
        anchors.leftMargin: Appearance.spacing.small

        y: Math.max(Config.border.thickness, Math.min(parent.height - Config.border.thickness - height, ShellState.networkY - height / 2))

        active: ShellState.network || opacity > 0
        opacity: ShellState.network ? 1 : 0
        scale: ShellState.network ? 1 : 0.85
        transformOrigin: Item.Left

        sourceComponent: Network {}

        Behavior on opacity {
            Anim {
                type: Anim.DefaultEffects
            }
        }

        Behavior on scale {
            Anim {
                type: Anim.FastSpatial
            }
        }
    }

    // Volume popout, pinned to its bar icon the same way as the Wi-Fi one.
    Loader {
        id: volume

        anchors.left: bar.right
        anchors.leftMargin: Appearance.spacing.small

        y: Math.max(Config.border.thickness, Math.min(parent.height - Config.border.thickness - height, ShellState.audioY - height / 2))

        active: ShellState.audio || opacity > 0
        opacity: ShellState.audio ? 1 : 0
        scale: ShellState.audio ? 1 : 0.85
        transformOrigin: Item.Left

        sourceComponent: Volume {}

        Behavior on opacity {
            Anim {
                type: Anim.DefaultEffects
            }
        }

        Behavior on scale {
            Anim {
                type: Anim.FastSpatial
            }
        }
    }

    // The bottom edge of the frame, as a trigger for the wallpaper picker.
    //
    // Invisible and narrow on purpose: it is masked into the shell's input
    // region, so its width is width the desktop below stops receiving clicks on.
    // Collapsed to nothing under a fullscreen window - the frame is already gone
    // there, and a live strip over a fullscreen video would swallow clicks meant
    // for it.
    Item {
        id: wallpaperZone

        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        // While the panel is up the zone grows to cover its whole footprint, so
        // the pointer moving off the strip and onto the panel never crosses a
        // strip of screen that belongs to neither.
        //
        // It has to be one region rather than two touching ones: the panel's own
        // hover does not arrive the instant the pointer reaches it - the enlarged
        // input region has to reach the compositor first - and the handoff was
        // losing that race, leaving both the zone and the panel un-hovered long
        // enough for the close timer to fire. The panel would shut just as you
        // reached it, and only re-open by going back to the very bottom edge.
        //
        // Declared before the panel Loader, so it sits *under* it and the
        // thumbnails still take their own clicks.
        implicitWidth: root.fullscreen ? 0 : ShellState.wallpapers ? Math.max(Config.wallpapers.hotZoneWidth, wallpapers.width) : Config.wallpapers.hotZoneWidth
        implicitHeight: root.fullscreen ? 0 : ShellState.wallpapers ? Config.border.thickness + wallpapers.height : Config.border.thickness

        MouseArea {
            id: wallpaperHotZone

            anchors.fill: parent
            hoverEnabled: !root.fullscreen

            // Opening on a dwell rather than on entry, so a pointer crossing the
            // bottom edge on its way somewhere else doesn't drag the panel up
            onEntered: wallpaperDwell.restart()
            onExited: wallpaperDwell.stop()
        }

        Timer {
            id: wallpaperDwell

            interval: Config.wallpapers.dwell
            onTriggered: ShellState.wallpapers = true
        }
    }

    // Closing is on a grace timer rather than immediate: the pointer has to cross
    // the gap between the zone and the panel to reach it.
    readonly property bool wallpapersHovered: wallpaperHotZone.containsMouse || wallpaperPanelHover.hovered

    onWallpapersHoveredChanged: {
        if (wallpapersHovered)
            wallpaperClose.stop();
        else if (ShellState.wallpapers)
            wallpaperClose.restart();
    }

    Timer {
        id: wallpaperClose

        interval: Config.wallpapers.closeDelay
        onTriggered: ShellState.wallpapers = false
    }

    // Wallpaper picker, rising out of the bottom edge rather than pinned to a bar
    // icon, so it gets neither the icon tracking nor the vertical clamp the
    // others need.
    Loader {
        id: wallpapers

        anchors.bottom: parent.bottom
        anchors.bottomMargin: Config.border.thickness
        anchors.horizontalCenter: parent.horizontalCenter

        active: ShellState.wallpapers || opacity > 0
        opacity: ShellState.wallpapers ? 1 : 0
        scale: ShellState.wallpapers ? 1 : 0.85
        transformOrigin: Item.Bottom

        sourceComponent: WallpaperPicker {}

        // A HoverHandler rather than a MouseArea: the picker's own items are
        // MouseAreas, and a parent MouseArea would never see the pointer once it
        // was over one of them - which is every part of the panel worth hovering.
        HoverHandler {
            id: wallpaperPanelHover
        }

        Behavior on opacity {
            Anim {
                type: Anim.DefaultEffects
            }
        }

        Behavior on scale {
            Anim {
                type: Anim.FastSpatial
            }
        }
    }

    // Bar tooltips live here because BarWrapper clips its contents. Hidden
    // while a popout is open, since both occupy the same strip of screen.
    Loader {
        id: tooltip

        // Held over while the bubble fades out, so it doesn't blank mid-fade
        property string lastText: ShellState.tooltipText

        readonly property bool shown: ShellState.tooltipText !== "" && !ShellState.session && !ShellState.network && !ShellState.audio && !ShellState.wallpapers

        anchors.left: bar.right
        anchors.leftMargin: Appearance.spacing.small

        y: Math.max(Config.border.thickness, Math.min(parent.height - Config.border.thickness - height, ShellState.tooltipY - height / 2))

        active: shown || opacity > 0
        opacity: shown ? 1 : 0

        sourceComponent: Tooltip {
            text: tooltip.lastText
        }

        Connections {
            target: ShellState

            function onTooltipTextChanged(): void {
                if (ShellState.tooltipText !== "")
                    tooltip.lastText = ShellState.tooltipText;
            }
        }

        Behavior on opacity {
            Anim {
                type: Anim.FastEffects
            }
        }
    }

    // Click outside to dismiss
    HyprlandFocusGrab {
        // Deliberately not ShellState.wallpapers. That panel opens on hover and
        // closes when the pointer leaves, so it never needs click-outside-to-
        // dismiss - and taking a grab for it costs the pointer events it lives
        // on.
        active: ShellState.session || ShellState.network || ShellState.audio
        windows: [root]
        onCleared: {
            ShellState.session = false;
            ShellState.network = false;
            ShellState.audio = false;
            ShellState.wallpapers = false;
        }
    }
}
