-- Drives modules/workspaces.lua against modules/workspaces.conf (window rules)
local assert_util = require("support.assert_util")
local mock_hl = require("support.mock_hl")

mock_hl.reset()
mock_hl.fresh_require("modules.workspaces")

local rules = mock_hl.find("hl.window_rule")
assert_util.equal(#rules, 4, "expected 4 hl.window_rule calls")

assert_util.equal(rules[1].args, {
    name = "move-kitty",
    match = { class = "kitty" },
    move = "100 100",
    animation = "popin",
}, "move-kitty rule mismatch")

assert_util.equal(rules[2].args, {
    name = "no-blur-firefox",
    match = { class = "firefox" },
    no_blur = true,
}, "no-blur-firefox rule mismatch")

assert_util.equal(rules[3].args, {
    name = "center-kitty-on-cursor",
    match = { class = "kitty" },
    move = "(cursor_x-(window_w*0.5)) (cursor_y-(window_h*0.5))",
}, "center-kitty-on-cursor rule mismatch")

-- NOTE: `stay_focused` was not in the (partial) wiki effects list fetched
-- during planning. Ported verbatim from workspaces.conf; needs a live
-- hyprctl reload to confirm this is still the right effect key.
assert_util.equal(rules[4].args, {
    name = "pinentry-stay-focused",
    match = { class = "(pinentry-)(.*)" },
    stay_focused = true,
}, "pinentry-stay-focused rule mismatch")
