-- Hyprland Lua configuration entrypoint.
-- See https://wiki.hypr.land/Configuring/Start/
--
-- Mirrors the module split from hyprland.conf's `source =` lines; each
-- module lives in modules/<name>.lua next to its .conf counterpart.

require("modules.binds")
require("modules.monitors")
require("modules.autostart")
require("modules.enviroment-variables")
require("modules.permissions")
require("modules.animations")
require("modules.input")
require("modules.workspaces")
