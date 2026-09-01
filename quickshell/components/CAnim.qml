//
// The colour counterpart to Anim. Every themed surface animates through this, so
// a wallpaper change washes over the shell instead of snapping.
//
import QtQuick
import qs.config

ColorAnimation {
    duration: Appearance.anim.durations.normal
    easing.type: Easing.BezierSpline
    easing.bezierCurve: Appearance.anim.curves.standard
}
