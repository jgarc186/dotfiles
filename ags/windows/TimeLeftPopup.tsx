import app from "ags/gtk4/app"
import { createBinding } from "ags"
import { Astal } from "ags/gtk4"

import Battery from "gi://AstalBattery"
import Network from "gi://AstalNetwork"

const { TOP, RIGHT } = Astal.WindowAnchor

export default function TimeLeftPopup() {
    const battery = Battery.get_default() 
    const network = Network.get_default()
    
    const timeToFull = createBinding(battery,"timeToFull")(timeToFull => {
        const baseTime = new Date(0)
        const { charging } = battery
        if (charging && timeToFull === 0) {
            return 'Fully charged'
        }

        if (charging && timeToFull === 0) {
            return 'Calculating time to full...'
        }

        // At this point we know we have valid time data
        const seconds = timeToFull
        baseTime.setSeconds(seconds)

        const batteryTime = `${baseTime.getUTCHours()}h ${baseTime.getUTCMinutes()}m ${baseTime.getUTCSeconds()}s`
        return `${charging ? 'Time to full' : 'Time to empty'}: ${batteryTime}`
    })

    const timeLeft = createBinding(battery,"timeToEmpty")(timeToEmpty => {
        const baseTime = new Date(0)
        const activeConnection = network.wifi.ssid; 
        const { charging } = battery
        if (!charging && timeToEmpty === 0) {
            return 'Calculating time to empty...'
        }

        // At this point we know we have valid time data
        const seconds = timeToEmpty
        baseTime.setSeconds(seconds)

        const batteryTime = `${baseTime.getUTCHours()}h ${baseTime.getUTCMinutes()}m ${baseTime.getUTCSeconds()}s`
        return `
            Time to empty: ${batteryTime}\n 
            Active Wifi connection: ${activeConnection}
        `
    })

    return (
        <window anchor={TOP | RIGHT} name="TimeLeftPopup" $={(self) => app.add_window(self)} css="background-color: rgba(21, 21, 32, 1); color: #94e2d5; margin-top: 20.3px; padding: 10px; border-radius: 25px;">
          <label label={ timeLeft } />
        </window>
    )
}

