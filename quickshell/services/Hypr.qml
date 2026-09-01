//
// Hyprland state, reshaped for the bar.
//
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.config

Singleton {
    id: root

    readonly property var workspaces: Hyprland.workspaces
    readonly property HyprlandWorkspace focusedWorkspace: Hyprland.focusedWorkspace
    readonly property HyprlandMonitor focusedMonitor: Hyprland.focusedMonitor
    readonly property int activeWsId: focusedWorkspace?.id ?? 1

    // id -> has windows. Recomputed on every Hyprland event, so it stays a plain
    // object rather than a model: consumers only ever index into it.
    readonly property var occupied: {
        const occ = {};
        for (const ws of Hyprland.workspaces.values)
            occ[ws.id] = (ws.lastIpcObject?.windows ?? 0) > 0;
        return occ;
    }

    function dispatch(request: string): void {
        Hyprland.dispatch(request);
    }

    function monitorFor(screen: ShellScreen): HyprlandMonitor {
        return Hyprland.monitorFor(screen);
    }

    function activeWsIdFor(screen: ShellScreen): int {
        if (!Config.bar.workspaces.perMonitorWorkspaces)
            return activeWsId;
        return monitorFor(screen)?.activeWorkspace?.id ?? activeWsId;
    }

    function specialWsFor(screen: ShellScreen): string {
        return monitorFor(screen)?.lastIpcObject.specialWorkspace?.name ?? "";
    }

    // Hyprland only reports window counts in the workspace IPC object, which
    // isn't refreshed by every event that can change it.
    Connections {
        target: Hyprland

        function onRawEvent(event: HyprlandEvent): void {
            const name = event.name;
            if (name.endsWith("v2"))
                return;

            if (name.includes("mon") || name.includes("workspace"))
                Hyprland.refreshMonitors();

            if (name.includes("window") || name.includes("workspace") || name.includes("fullscreen") || name === "closelayer" || name === "openlayer")
                Hyprland.refreshWorkspaces();
        }
    }
}
