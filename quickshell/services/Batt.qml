pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

Singleton {
    id: root

    readonly property UPowerDevice device: UPower.displayDevice
    readonly property bool available: device?.isLaptopBattery ?? false
    readonly property real percentage: device?.percentage ?? 0
    readonly property bool charging: device?.state === UPowerDeviceState.Charging || device?.state === UPowerDeviceState.FullyCharged
    readonly property bool low: available && percentage <= 0.2 && !charging

    // Seconds until empty/full. UPower reports 0 when it has no estimate yet -
    // right after a plug/unplug, or while the rate is still settling.
    readonly property int timeToEmpty: device?.timeToEmpty ?? 0
    readonly property int timeToFull: device?.timeToFull ?? 0

    // What the tooltip shows: percentage, plus an estimate when there is one
    readonly property string summary: {
        const pct = `${Math.round(percentage * 100)}%`;

        if (device?.state === UPowerDeviceState.FullyCharged)
            return `${pct} · Full`;

        if (charging)
            return timeToFull > 0 ? `${pct} · ${formatTime(timeToFull)} to full` : `${pct} · Charging`;

        return timeToEmpty > 0 ? `${pct} · ${formatTime(timeToEmpty)} left` : pct;
    }

    // What the popout's status line shows: the state in words, without the
    // percentage the popout already shows large
    readonly property string status: {
        switch (device?.state) {
        case UPowerDeviceState.FullyCharged:
            return "Fully charged";
        case UPowerDeviceState.Charging:
            return timeToFull > 0 ? `Charging · ${formatTime(timeToFull)} to full` : "Charging";
        case UPowerDeviceState.Discharging:
            return timeToEmpty > 0 ? `On battery · ${formatTime(timeToEmpty)} left` : "On battery";
        case UPowerDeviceState.PendingCharge:
            return "Plugged in · not charging";
        }
        return "";
    }

    // The laptop's own battery, for health. displayDevice is UPower's
    // composite of every power-supply battery and reports no health at all
    // (healthSupported false, 0%) even when the battery behind it does.
    readonly property UPowerDevice battery: UPower.devices.values.find(d => d.isLaptopBattery) ?? null

    // Watts; positive both ways, the state says which way it flows
    readonly property real rate: Math.abs(battery?.changeRate ?? 0)
    // Watt-hours the battery holds when full today
    readonly property real fullEnergy: battery?.energyCapacity ?? 0

    // Full capacity as a fraction of what it held new. UPower's own figure
    // where it has one (0-100, unlike percentage), else worked out from sysfs.
    readonly property real health: {
        if (battery?.healthSupported && battery.healthPercentage > 0)
            return battery.healthPercentage / 100;
        return designEnergy > 0 ? fullEnergy / designEnergy : 0;
    }

    readonly property string healthRating: health >= 0.8 ? "Good" : health >= 0.6 ? "Fair" : "Poor"

    // What UPower doesn't pass through, read from the kernel's power_supply
    // uevent: one file with every field as KEY=value. -1 / "" when the driver
    // doesn't report one.
    property int cycles: -1
    property real temperature: -1
    property string technology: ""
    property string manufacturer: ""
    property real designEnergy: 0

    // Ref count of widgets showing the sysfs figures, so the temperature is
    // only polled while someone is looking at it
    property int watchers: 0

    function watch(): void {
        watchers++;
    }

    function unwatch(): void {
        watchers = Math.max(0, watchers - 1);
    }

    function formatTime(seconds: int): string {
        const hours = Math.floor(seconds / 3600);
        const mins = Math.round((seconds % 3600) / 60);

        if (hours === 0)
            return `${mins}m`;
        // Rounding minutes can land on 60; roll it into the hour
        if (mins === 60)
            return `${hours + 1}h`;
        return mins === 0 ? `${hours}h` : `${hours}h ${mins}m`;
    }

    Timer {
        interval: 5000
        running: root.watchers > 0 && uevent.path !== ""
        repeat: true
        triggeredOnStart: true
        onTriggered: uevent.reload()
    }

    // sysfs, like procfs, never fires inotify, hence the timer above
    FileView {
        id: uevent

        path: root.battery ? `/sys/class/power_supply/${root.battery.nativePath}/uevent` : ""
        onLoaded: {
            const fields = {};
            for (const line of text().split("\n")) {
                const eq = line.indexOf("=");
                if (line.startsWith("POWER_SUPPLY_") && eq > 0)
                    fields[line.slice(13, eq)] = line.slice(eq + 1);
            }

            root.cycles = "CYCLE_COUNT" in fields ? parseInt(fields.CYCLE_COUNT) : -1;
            // Tenths of a degree
            root.temperature = "TEMP" in fields ? parseInt(fields.TEMP) / 10 : -1;
            root.technology = fields.TECHNOLOGY ?? "";
            root.manufacturer = fields.MANUFACTURER ?? "";

            // Drivers report capacity as energy (µWh) or as charge (µAh). For
            // charge, UPower converts at the minimum design voltage, so this
            // does the same and the two health figures agree.
            if ("ENERGY_FULL_DESIGN" in fields)
                root.designEnergy = parseInt(fields.ENERGY_FULL_DESIGN) / 1e6;
            else if ("CHARGE_FULL_DESIGN" in fields && "VOLTAGE_MIN_DESIGN" in fields)
                root.designEnergy = parseInt(fields.CHARGE_FULL_DESIGN) * parseInt(fields.VOLTAGE_MIN_DESIGN) / 1e12;
            else
                root.designEnergy = 0;
        }
    }
}
