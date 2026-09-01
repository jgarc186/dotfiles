//
// Light/dark switch for the whole desktop.
//
// The icon shows the mode currently in effect, not the one clicking would move
// to - the bar reports state everywhere else, and a button that displays its
// own opposite reads as a bug.
//
import QtQuick
import qs.components
import qs.config
import qs.services

Item {
    id: root

    readonly property string tooltip: Theme.busy ? "Switching…" : Theme.light ? "Light mode" : "Dark mode"

    implicitWidth: icon.implicitHeight + Appearance.padding.small
    implicitHeight: icon.implicitHeight

    onTooltipChanged: ShellState.updateTooltip(root, tooltip)

    StateLayer {
        // Square the hit area up without stretching the row
        anchors.fill: undefined
        anchors.centerIn: parent
        implicitWidth: implicitHeight
        implicitHeight: icon.implicitHeight + Appearance.padding.small
        radius: Appearance.rounding.full
        color: Colours.palette.m3secondary

        // matugen rewrites every template on the way through, so a second run
        // started over the first interleaves their writes
        disabled: Theme.busy

        onClicked: Theme.toggle()
        onEntered: ShellState.showTooltip(root, root.tooltip, root.mapToItem(null, 0, root.height / 2).y)
        onExited: ShellState.hideTooltip(root)
    }

    MaterialIcon {
        id: icon

        anchors.centerIn: parent

        animate: true
        text: Theme.light ? "light_mode" : "dark_mode"
        color: Colours.palette.m3secondary
        fill: Theme.busy ? 1 : 0

        // The regenerated palette lands a beat after the click, so without this
        // the icon is the only thing that hasn't moved yet
        opacity: Theme.busy ? 0.6 : 1

        Behavior on opacity {
            Anim {
                type: Anim.DefaultEffects
            }
        }
    }
}
