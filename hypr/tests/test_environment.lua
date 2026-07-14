-- Drives modules/enviroment-variables.lua against modules/enviroment-variables.conf
local assert_util = require("support.assert_util")
local mock_hl = require("support.mock_hl")

mock_hl.reset()
mock_hl.fresh_require("modules.enviroment-variables")

local calls = mock_hl.find("hl.env")
assert_util.equal(#calls, 2, "expected 2 hl.env calls")
assert_util.equal(calls[1].args, { name = "XCURSOR_SIZE", value = "24" }, "XCURSOR_SIZE mismatch")
assert_util.equal(calls[2].args, { name = "HYPRCURSOR_SIZE", value = "24" }, "HYPRCURSOR_SIZE mismatch")
