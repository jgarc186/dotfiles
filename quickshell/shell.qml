//@ pragma DefaultEnv QS_NO_RELOAD_POPUP=1
//@ pragma DefaultEnv QSG_RENDER_LOOP=threaded

//
// A Material 3 shell for Hyprland, in the shape of caelestia-dots/shell.
//
// Layout is a left vertical bar sitting inside a rounded frame drawn around the
// whole screen. Colours come from matugen (services/Scheme.qml), geometry and
// motion from the M3 tokens in config/Appearance.qml.
//
import Quickshell
import "modules"
import "modules/border"
import qs.config

ShellRoot {
    Variants {
        model: Quickshell.screens

        Scope {
            id: scope

            required property ShellScreen modelData

            // The bar's full width, including the padding that doubles as the
            // frame's left edge. Shared so the exclusion zone matches exactly.
            readonly property int barWidth: Appearance.sizes.bar.innerWidth + Math.max(Appearance.padding.small, Config.border.thickness) * 2

            Exclusions {
                screen: scope.modelData
                barWidth: scope.barWidth
            }

            ShellWindow {
                screen: scope.modelData
                barWidth: scope.barWidth
            }
        }
    }
}
