-- See https://wiki.hypr.land/Configuring/Basics/Monitors/

hl.monitor({
    output = "",
    mode = "highres",
    position = "auto",
    scale = "auto",
    mirror = "HDMI-A-1",
})

-- Dell external monitor (HDMI-A-1)
-- Native: 1920x1200@60, scaled slightly up for comfortable UI
hl.monitor({
    output = "HDMI-A-1",
    mode = "highres",
    position = "auto",
    scale = "auto",
})
