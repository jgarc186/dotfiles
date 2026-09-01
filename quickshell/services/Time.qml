pragma Singleton

import QtQuick
import Quickshell
import qs.config

Singleton {
    id: root

    readonly property date date: clock.date
    readonly property int hours: clock.hours
    readonly property int minutes: clock.minutes

    readonly property string timeStr: format(Config.general.useTwelveHourClock ? "hh:mm:A" : "HH:mm")
    readonly property list<string> timeComponents: timeStr.split(":")
    readonly property string hourStr: timeComponents[0] ?? ""
    readonly property string minuteStr: timeComponents[1] ?? ""
    readonly property string amPmStr: timeComponents[2] ?? ""

    function format(fmt: string): string {
        return Qt.formatDateTime(clock.date, fmt);
    }

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }
}
