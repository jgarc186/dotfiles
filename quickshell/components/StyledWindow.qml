import Quickshell
import Quickshell.Wayland

// qmllint disable uncreatable-type
PanelWindow {
    // Namespaced so Hyprland layer rules can target the shell
    // (e.g. `layerrule = blur, caelestia-jose:.*`)
    property string name

    WlrLayershell.namespace: `quickshell-jose:${name}`
    color: "transparent"
}
