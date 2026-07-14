-- Drives modules/input.lua against modules/input.conf
local assert_util = require("support.assert_util")
local mock_hl = require("support.mock_hl")

mock_hl.reset()
mock_hl.fresh_require("modules.input")

local config_calls = mock_hl.find("hl.config")
assert_util.equal(#config_calls, 1, "expected 1 hl.config call")
assert_util.equal(config_calls[1].args, {
    input = {
        kb_layout = "us",
        kb_variant = "",
        kb_model = "",
        kb_options = "",
        kb_rules = "",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = { natural_scroll = false },
    },
}, "input config mismatch")

local device_calls = mock_hl.find("hl.device")
assert_util.equal(#device_calls, 1, "expected 1 hl.device call")
assert_util.equal(device_calls[1].args,
    { name = "epic-mouse-v1", sensitivity = -0.5 },
    "device mismatch")
