-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/ for more

-- Move kitty to 100 100 and add an anim style
hl.window_rule({
    name = "move-kitty",
    match = { class = "kitty" },

    move = "100 100",
    animation = "popin",
})

-- Disable blur for firefox
hl.window_rule({
    name = "no-blur-firefox",
    match = { class = "firefox" },

    no_blur = true,
})

-- Move kitty to the center of the cursor
hl.window_rule({
    name = "center-kitty-on-cursor",
    match = { class = "kitty" },

    move = "(cursor_x-(window_w*0.5)) (cursor_y-(window_h*0.5))",
})

-- Fix pinentry losing focus
-- NOTE: `stay_focused` wasn't confirmed against the full wiki effects list;
-- ported verbatim, needs a live hyprctl reload to double check.
hl.window_rule({
    name = "pinentry-stay-focused",
    match = { class = "(pinentry-)(.*)" },

    stay_focused = true,
})
