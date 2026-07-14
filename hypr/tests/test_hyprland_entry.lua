-- Integration test: requiring hyprland.lua itself should wire up every module.
-- Closest thing to an end-to-end check without a real compositor.
local assert_util = require("support.assert_util")
local mock_hl = require("support.mock_hl")

local module_names = {
    "hyprland",
    "modules.programs",
    "modules.monitors",
    "modules.autostart",
    "modules.enviroment-variables",
    "modules.permissions",
    "modules.animations",
    "modules.input",
    "modules.binds",
    "modules.workspaces",
}

for _, name in ipairs(module_names) do
    package.loaded[name] = nil
end

mock_hl.reset()
require("hyprland")

assert_util.truthy(mock_hl.count("hl.monitor") == 2, "hyprland.lua should wire up modules.monitors")
assert_util.truthy(mock_hl.count("hl.env") == 2, "hyprland.lua should wire up modules.enviroment-variables")
assert_util.truthy(mock_hl.count("hl.on") == 1, "hyprland.lua should wire up modules.autostart")
assert_util.truthy(mock_hl.count("hl.window_rule") == 4, "hyprland.lua should wire up modules.workspaces")
assert_util.truthy(mock_hl.count("hl.device") == 1, "hyprland.lua should wire up modules.input")
assert_util.truthy(mock_hl.count("hl.bind") > 0, "hyprland.lua should wire up modules.binds")
