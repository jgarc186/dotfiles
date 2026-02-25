#!/usr/bin/env -S ags run
import app from "ags/gtk4/app"

import MainBar from "./components/MainBar"
import TimeLeftPopup from "./windows/TimeLeftPopup"

app.start({
  main() {
   MainBar(),
   TimeLeftPopup()
  },
})
