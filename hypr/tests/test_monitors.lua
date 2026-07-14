-- Drives modules/monitors.lua against modules/monitors.conf
local assert_util = require("support.assert_util")
local mock_hl = require("support.mock_hl")

mock_hl.reset()
mock_hl.fresh_require("modules.monitors")

local calls = mock_hl.find("hl.monitor")
assert_util.equal(#calls, 2, "expected 2 hl.monitor calls")

assert_util.equal(calls[1].args, {
    output = "",
    mode = "highres",
    position = "auto",
    scale = "auto",
}, "default catch-all monitor mismatch")

assert_util.equal(calls[2].args, {
    output = "LVDS-1",
    mode = "highres",
    position = "auto",
    scale = "auto",
    mirror = "HDMI-A-1",
}, "LVDS-1 monitor mismatch")
