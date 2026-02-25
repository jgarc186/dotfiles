import { createState } from "ags"

import { Astal } from "ags/gtk4"
import { createPoll } from "ags/time"
import app from "ags/gtk4/app"
import Gtk from "gi://Gtk"
import Gdk from "gi://Gdk?version=4.0"
import Hyprland from "gi://AstalHyprland"
import Bluetooth from "gi://AstalBluetooth"
import Network from "gi://AstalNetwork"

import BatteryLife from "./widgets/BatteryLife"

const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

export default function MainBar() {
    const [ displayWorkspaces, setDisplayWorkspaces ] = createState(false)
    const clock = createPoll("", 1000, "date")
    const currentBar = app.get_window("HyprLandWorkspaces")

    const network = Network.get_default()
    const bluetooth = Bluetooth.get_default()
    
    const hyprland = Hyprland.get_default()
    const clients = hyprland.get_clients()

    function displayBluetoothDevices() {
        bluetooth.get_devices().forEach(({ name })=> {
            console.log('device name:', name)
        })
    }

    function displayWifi() {
        const activeConnection = network.wifi.ssid; 

        console.log('ssid: ', activeConnection)
    }

    return (
    <>
      <window visible name="MainBar" anchor={TOP | LEFT | RIGHT} application={app}>
        <centerbox css="background-color: rgba(21, 21, 32, 1); color: white; padding: 0 10px 0 10px;">
            <box 
                $type="start" 
            >
                <label css="font-size: 20px;" label="󰣇"/>
                <Gtk.GestureClick
                    propagationPhase={Gtk.PropagationPhase.CAPTURE}
                    button={Gdk.BUTTON_PRIMARY}
                    onPressed={() => setDisplayWorkspaces((oldValue) => !oldValue)}
                />
            </box>
            <label
                $type="center"
                label={clock}
            />
        </centerbox>
      </window>
      <window visible name="RightSideBar" anchor={TOP | RIGHT} application={app}>
        <box $type="end" css="background-color: rgba(21, 21, 32, 1); color: white; padding: 0 10px 0 10px;">
            <box>
            {/* <label css="color: #cba6f7" label=" " /> */}
                <Gtk.GestureClick
                    propagationPhase={Gtk.PropagationPhase.CAPTURE}
                    button={Gdk.BUTTON_PRIMARY}
                    onPressed={ displayBluetoothDevices }
                />
            </box>
            <box>
             <label css="color: #94e2d5;" label="󰤨  " />
                <Gtk.GestureClick
                    propagationPhase={Gtk.PropagationPhase.CAPTURE}
                    button={Gdk.BUTTON_PRIMARY}
                    onPressed={ displayWifi }
                />
            </box>
            <BatteryLife />
        </box>
      </window>
      <window visible={displayWorkspaces} name="HyprLandWorkspaces"  css="background-color: rgba(21, 21, 32, 1); color: white; padding: 0 10px 0 10px;">
        <box>
            {clients.map(({ title }) => (
                <label css="background-color: rgba(21, 21, 32, 1); color: white; padding: 0 10px 0 10px;" label={title} />
            ))}
        </box>
      </window> 
      </>
    )
}
