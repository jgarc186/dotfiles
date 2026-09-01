-- Drives modules/monitors.lua
local assert_util = require("support.assert_util")
local mock_hl = require("support.mock_hl")

mock_hl.reset()
mock_hl.fresh_require("modules.monitors")

local calls = mock_hl.find("hl.monitor")
assert_util.equal(#calls, 2, "expected 2 hl.monitor calls")

-- The catch-all carries the mirror, so any panel that isn't named below - the
-- laptop's own eDP included - shows what HDMI-A-1 shows. HDMI-A-1 itself is
-- matched by the more specific rule after it, so it never mirrors itself.
assert_util.equal(calls[1].args, {
    output = "",
    mode = "highres",
    position = "auto",
    scale = "auto",
    mirror = "HDMI-A-1",
}, "default catch-all monitor mismatch")

assert_util.equal(calls[2].args, {
    output = "HDMI-A-1",
    mode = "highres",
    position = "auto",
    scale = "auto",
}, "HDMI-A-1 monitor mismatch")
