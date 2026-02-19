import { Astal } from "ags/gtk4"
import { createPoll } from "ags/time"
import app from "ags/gtk4/app"

const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

export default function MainBar() {
    const clock = createPoll("", 1000, "date")
    const batteryPercent = createPoll("", 1000, "cat /sys/class/power_supply/BAT0/capacity")
    const currentBar = app.get_window("MainBar")

    return (
    <>
      <window visible name="MainBar" anchor={TOP | LEFT | RIGHT} application={app}>
        <label
            css="background-color: rgba(21, 21, 32, 1); color: white;"
            label={clock}
        />
      </window>
      <window visible name="MainBar" anchor={TOP | RIGHT} application={app}>
        <label 
            css="padding-right: 1em; background-color: rgba(21, 21, 32, 1); color: white;"
            label={batteryPercent} 
        />
      </window>
    </>
    )
}
