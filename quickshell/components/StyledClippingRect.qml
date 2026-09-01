import QtQuick
import Quickshell.Widgets

// Clips children to the rounded corners, which a plain Rectangle won't do
ClippingRectangle {
    color: "transparent"

    Behavior on color {
        CAnim {}
    }
}
