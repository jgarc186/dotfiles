-- See https://wiki.hypr.land/Configuring/Basics/Variables/

hl.config({
    general = {
        gaps_in = 7,
        gaps_out = 15,

        border_size = 1,

        col = {
            active_border = "rgba(b4befeaa)",
            inactive_border = "rgba(595959aa)",
        },

        resize_on_border = true,

        allow_tearing = false,

        layout = "master",
    },

    decoration = {
        rounding = 15,
        rounding_power = 2,

        active_opacity = 1.0,
        inactive_opacity = 0.9,

        shadow = {
            enabled = true,
            range = 13,
            render_power = 3,
            color = "rgba(121212aa)",
        },

        blur = {
            enabled = true,
            size = 15,
            passes = 2,

            vibrancy = 0.5,
            vibrancy_darkness = 0.2,
        },
    },

    animations = {
        enabled = true,
    },
})

-- Default curves, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/#curves
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
-- animations.conf had `bezier = linear, 8,8,1,1` — a pre-existing typo:
-- (8,8) exceeds Hyprland's real max of 2.00 per control point and errors
-- at load. Fixed to the actual linear bezier (0,0)->(1,1).
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })

-- Default animations, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.animation({ leaf = "windows",    enabled = true, speed = 7,  bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",  enabled = true, speed = 7,  bezier = "easeOutQuint", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7,  bezier = "linear",       style = "slide" })
hl.animation({ leaf = "border",       enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle",  enabled = true, speed = 8,  bezier = "default" })
hl.animation({ leaf = "fade",         enabled = true, speed = 7,  bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 8, bezier = "myBezier", style = "slidefade 10%" })
hl.animation({ leaf = "layersIn",   enabled = true, speed = 8, bezier = "myBezier", style = "slidefade 10%" })
hl.animation({ leaf = "layersOut",  enabled = true, speed = 8, bezier = "myBezier", style = "slidefade 10%" })

-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/
-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/
-- See https://wiki.hypr.land/Configuring/Variables/#misc
hl.config({
    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo = true,
    },
})
