import { createBinding, createState } from "ags"

import app from "ags/gtk4/app"
import Gtk from "gi://Gtk"
import Gdk from "gi://Gdk?version=4.0"
import Battery from "gi://AstalBattery"

export default function BatteryLife() {
    const battery = Battery.get_default() 
    const [showTimeLeftPopup, setShowTimeLeftPopup ] = createState(false)

    const percent = createBinding(battery, "percentage")(v => {
        const value = Math.floor(v * 100) 
        const { charging }= battery

        if (charging) {
            return value >= 98 ? `󰁹 ${value}%` : `󰂄 ${value}%`
        }

        const formatIcons = [
            [100, "󰁹"],
            [90, "󰂂"],
            [80, "󰂁"],
            [70, "󰂀"],
            [60, "󰁿"], 
            [50, "󰁾"],
            [40, "󰁽"],
            [30, "󰁼"],
            [20, "󰁻"], 
            [10, "󰁺"],
            [0, "󰂎"], 
        ]

        const icon = formatIcons.find(([threshhold]) => value >= threshhold)?.[1] ??  "󰂎"
        return `${icon} ${value}%`
    })

    const handleTimeLeftPopup = () => {
        try {
            const bar = app.get_window("TimeLeftPopup")
            setShowTimeLeftPopup(prev => !prev)
            if (bar) {
                bar.visible = showTimeLeftPopup() 
            }
        } catch (e) {
            console.log('here is the error: ', e)
        }
    }

    return (
        <>
            <Gtk.GestureClick
                propagationPhase={Gtk.PropagationPhase.CAPTURE}
                button={Gdk.BUTTON_PRIMARY}
                onPressed={ handleTimeLeftPopup }
            />
            <label css="color: #94e2d5;" label={ percent } />
        </>
    )
}
