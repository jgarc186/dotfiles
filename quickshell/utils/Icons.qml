//
// Material Symbols name lookups.
//
pragma Singleton

import QtQuick
import Quickshell

Singleton {
    function getVolumeIcon(volume: real, muted: bool): string {
        if (muted)
            return "no_sound";
        if (volume >= 0.5)
            return "volume_up";
        if (volume > 0)
            return "volume_down";
        return "volume_mute";
    }

    function getMicIcon(volume: real, muted: bool): string {
        return !muted && volume > 0 ? "mic" : "mic_off";
    }

    function getNetworkIcon(strength: int): string {
        if (strength >= 80)
            return "network_wifi";
        if (strength >= 60)
            return "network_wifi_3_bar";
        if (strength >= 40)
            return "network_wifi_2_bar";
        if (strength >= 20)
            return "network_wifi_1_bar";
        return "signal_wifi_0_bar";
    }

    function getBluetoothIcon(icon: string): string {
        if (icon.includes("headset") || icon.includes("headphones"))
            return "headphones";
        if (icon.includes("audio"))
            return "speaker";
        if (icon.includes("phone"))
            return "smartphone";
        if (icon.includes("mouse"))
            return "mouse";
        if (icon.includes("keyboard"))
            return "keyboard";
        return "bluetooth";
    }

    function getBatteryIcon(percentage: real, charging: bool): string {
        if (percentage >= 1)
            return charging ? "battery_charging_full" : "battery_full";
        let level = Math.floor(percentage * 7);
        // battery_charging_40 and _10 don't exist; fall back a step
        if (charging && (level === 4 || level === 1))
            level--;
        return charging ? `battery_charging_${(level + 3) * 10}` : `battery_${level}_bar`;
    }
}
