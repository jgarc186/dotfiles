-- modules/permissions.conf is entirely commented out; modules/permissions.lua
-- should mirror that (no live hl.* calls), not silently enable anything.
local assert_util = require("support.assert_util")
local mock_hl = require("support.mock_hl")

mock_hl.reset()
mock_hl.fresh_require("modules.permissions")

assert_util.equal(#mock_hl.calls(), 0,
    "permissions.lua should make zero hl.* calls, matching the fully-commented permissions.conf")
