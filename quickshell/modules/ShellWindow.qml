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

    // Wi-Fi popout, centred on the bar rather than pinned to its icon: the
    // list is tall enough that tracking the icon would run it off-screen.
    Loader {
        id: network

        anchors.left: bar.right
        anchors.leftMargin: Appearance.spacing.small
        anchors.verticalCenter: parent.verticalCenter

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

    // Bar tooltips live here because BarWrapper clips its contents. Hidden
    // while a popout is open, since both occupy the same strip of screen.
    Loader {
        id: tooltip

        // Held over while the bubble fades out, so it doesn't blank mid-fade
        property string lastText: ShellState.tooltipText

        readonly property bool shown: ShellState.tooltipText !== "" && !ShellState.session && !ShellState.network

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
        active: ShellState.session || ShellState.network
        windows: [root]
        onCleared: {
            ShellState.session = false;
            ShellState.network = false;
        }
    }
}
