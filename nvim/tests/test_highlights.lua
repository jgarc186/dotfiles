-- Source-level checks on the custom highlight groups defined in the
-- catppuccin config block of plugins.lua. That config function only runs
-- when catppuccin loads (a real plugin), so it can't be executed in the
-- headless test env — we assert on the source text instead.
--
-- Guards a class of silent bug: a highlight group DEFINED under a
-- misspelled name never matches the (correctly spelled) name that other
-- configs `highlight link` against, so the styling silently no-ops.
local A = require("support.assert_util")
local H = require("support.harness")

local plugins = H.read("lua/user/plugins.lua")

-- The typo that shipped: CursorLinmeBg. telescope.lua links
-- TelescopeBorder -> CursorLineBg, so the definition must use that spelling.
A.falsy(plugins:find("CursorLinmeBg", 1, true),
    "misspelled highlight group 'CursorLinmeBg' present in plugins.lua")
A.truthy(plugins:find("CursorLineBg", 1, true),
    "highlight group 'CursorLineBg' (linked by telescope.lua) not defined")

-- The name telescope.lua links to must exist as a definition somewhere in
-- the config, or the link resolves to nothing.
local telescope = H.read("lua/user/plugins/telescope.lua")
if telescope:find("CursorLineBg", 1, true) then
    A.truthy(plugins:find("nvim_set_hl.-CursorLineBg"),
        "telescope links CursorLineBg but plugins.lua never defines it via nvim_set_hl")
end
