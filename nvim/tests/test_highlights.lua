-- Source-level checks on the custom highlight groups defined in
-- lua/user/theme.lua.
--
-- test_theme.lua asserts these groups exist at runtime; this file guards the
-- spelling in the source, which is the failure that stays silent: a group
-- DEFINED under a misspelled name never matches the (correctly spelled) name
-- other configs `highlight link` against, so the styling no-ops with no error.
local A = require("support.assert_util")
local H = require("support.harness")

local theme = H.read("lua/user/theme.lua")

-- The typo that shipped: CursorLinmeBg. telescope.lua links
-- TelescopeBorder -> CursorLineBg, so the definition must use that spelling.
A.falsy(theme:find("CursorLinmeBg", 1, true),
    "misspelled highlight group 'CursorLinmeBg' present in theme.lua")
A.truthy(theme:find("CursorLineBg", 1, true),
    "highlight group 'CursorLineBg' (linked by telescope.lua) not defined")

-- The name telescope.lua links to must exist as a definition somewhere in
-- the config, or the link resolves to nothing.
local telescope = H.read("lua/user/plugins/telescope.lua")
if telescope:find("CursorLineBg", 1, true) then
    A.truthy(theme:find("nvim_set_hl.-CursorLineBg"),
        "telescope links CursorLineBg but theme.lua never defines it via nvim_set_hl")
end

-- lualine.lua colours its sections by highlight-group name rather than by a
-- lualine theme table, so these have to exist too.
local lualine = H.read("lua/user/plugins/lualine.lua")
if lualine:find("StatusLineNonText", 1, true) then
    A.truthy(theme:find("nvim_set_hl.-StatusLineNonText"),
        "lualine uses StatusLineNonText but theme.lua never defines it")
end
