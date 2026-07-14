-- Drives modules/animations.lua against modules/animations.conf
local assert_util = require("support.assert_util")
local mock_hl = require("support.mock_hl")

mock_hl.reset()
mock_hl.fresh_require("modules.animations")

local config_calls = mock_hl.find("hl.config")
assert_util.equal(#config_calls, 2,
    "expected 2 hl.config calls (general/decoration/animations, then dwindle/master/misc)")

assert_util.equal(config_calls[1].args, {
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
}, "general/decoration/animations config mismatch")

assert_util.equal(config_calls[2].args, {
    dwindle = { preserve_split = true },
    master = { new_status = "master" },
    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo = true,
    },
}, "dwindle/master/misc config mismatch")

local curve_calls = mock_hl.find("hl.curve")
assert_util.equal(#curve_calls, 3, "expected 3 hl.curve calls")

assert_util.equal(curve_calls[1].args,
    { name = "easeOutQuint", spec = { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } } },
    "easeOutQuint curve mismatch")
assert_util.equal(curve_calls[2].args,
    { name = "linear", spec = { type = "bezier", points = { { 8, 8 }, { 1, 1 } } } },
    "linear curve mismatch (ported verbatim from animations.conf, incl. out-of-range points)")
assert_util.equal(curve_calls[3].args,
    { name = "myBezier", spec = { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } } },
    "myBezier curve mismatch")

local anim_calls = mock_hl.find("hl.animation")
assert_util.equal(#anim_calls, 9, "expected 9 hl.animation calls")

local expected_anims = {
    { leaf = "windows",    enabled = true, speed = 7,  bezier = "easeOutQuint" },
    { leaf = "windowsIn",  enabled = true, speed = 7,  bezier = "easeOutQuint", style = "slide" },
    { leaf = "windowsOut", enabled = true, speed = 7,  bezier = "linear",       style = "slide" },
    { leaf = "border",       enabled = true, speed = 10, bezier = "default" },
    { leaf = "borderangle",  enabled = true, speed = 8,  bezier = "default" },
    { leaf = "fade",         enabled = true, speed = 7,  bezier = "default" },
    { leaf = "workspaces", enabled = true, speed = 8, bezier = "myBezier", style = "slidefade 10%" },
    { leaf = "layersIn",   enabled = true, speed = 8, bezier = "myBezier", style = "slidefade 10%" },
    { leaf = "layersOut",  enabled = true, speed = 8, bezier = "myBezier", style = "slidefade 10%" },
}

for i, expected in ipairs(expected_anims) do
    assert_util.equal(anim_calls[i].args, expected,
        "animation #" .. i .. " (" .. expected.leaf .. ") mismatch")
end
