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
    WlrLayershell.keyboardFocus: ShellState.session ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    mask: Region {
        item: bar

        Region {
            item: session
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

    // Click outside to dismiss
    HyprlandFocusGrab {
        active: ShellState.session
        windows: [root]
        onCleared: ShellState.session = false
    }
}
