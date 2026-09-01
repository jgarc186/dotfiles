pragma Singleton

import QtQuick
import Quickshell
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
}
