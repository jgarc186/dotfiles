//
// The writable shape of a Material 3 colour scheme.
//
// Two objects in services/Colours.qml are instances of this: `current`, which is
// the matugen-generated Scheme.qml, and `preview`, which the wallpaper picker
// fills from a `matugen --dry-run` so the shell can be retinted without anything
// being written to disk. Keeping one component means the two can't drift apart -
// the property list lives here and the template only assigns to it.
//
// Roles are the M3 set, named as matugen emits them: `m3` + the role in camel
// case, which maps onto matugen's snake_case JSON keys by a plain conversion
// (m3onPrimaryFixedVariant <-> on_primary_fixed_variant). Colours.load() relies
// on that, so a role named any other way here would silently never be filled.
//
import QtQuick

QtObject {
    property color m3background: "transparent"
    property color m3error: "transparent"
    property color m3errorContainer: "transparent"
    property color m3inverseOnSurface: "transparent"
    property color m3inversePrimary: "transparent"
    property color m3inverseSurface: "transparent"
    property color m3onBackground: "transparent"
    property color m3onError: "transparent"
    property color m3onErrorContainer: "transparent"
    property color m3onPrimary: "transparent"
    property color m3onPrimaryContainer: "transparent"
    property color m3onPrimaryFixed: "transparent"
    property color m3onPrimaryFixedVariant: "transparent"
    property color m3onSecondary: "transparent"
    property color m3onSecondaryContainer: "transparent"
    property color m3onSecondaryFixed: "transparent"
    property color m3onSecondaryFixedVariant: "transparent"
    property color m3onSurface: "transparent"
    property color m3onSurfaceVariant: "transparent"
    property color m3onTertiary: "transparent"
    property color m3onTertiaryContainer: "transparent"
    property color m3onTertiaryFixed: "transparent"
    property color m3onTertiaryFixedVariant: "transparent"
    property color m3outline: "transparent"
    property color m3outlineVariant: "transparent"
    property color m3primary: "transparent"
    property color m3primaryContainer: "transparent"
    property color m3primaryFixed: "transparent"
    property color m3primaryFixedDim: "transparent"
    property color m3scrim: "transparent"
    property color m3secondary: "transparent"
    property color m3secondaryContainer: "transparent"
    property color m3secondaryFixed: "transparent"
    property color m3secondaryFixedDim: "transparent"
    property color m3shadow: "transparent"
    property color m3surface: "transparent"
    property color m3surfaceBright: "transparent"
    property color m3surfaceContainer: "transparent"
    property color m3surfaceContainerHigh: "transparent"
    property color m3surfaceContainerHighest: "transparent"
    property color m3surfaceContainerLow: "transparent"
    property color m3surfaceContainerLowest: "transparent"
    property color m3surfaceDim: "transparent"
    property color m3surfaceTint: "transparent"
    property color m3surfaceVariant: "transparent"
    property color m3tertiary: "transparent"
    property color m3tertiaryContainer: "transparent"
    property color m3tertiaryFixed: "transparent"
    property color m3tertiaryFixedDim: "transparent"

    // The mode matugen generated in, straight from `{{mode}}`. Empty on a scheme
    // that predates the template writing it, which Colours falls back to
    // inferring from the surface luminance.
    property string mode
}
