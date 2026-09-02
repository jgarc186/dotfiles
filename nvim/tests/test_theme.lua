-- Real-state test for the matugen theme wiring.
--
-- Two separate things fail here, in different ways:
--
--   * The template can silently pin one mode. Every other matugen template
--     uses `.default.hex` — whatever `--mode` the run used — while this one
--     shipped with `.dark.hex`, so a light-mode run rendered dark colours and
--     the editor stopped matching the rest of the desktop. That's the bug this
--     file was written for.
--   * lua/user/theme.lua has to apply the colourscheme AND re-apply the local
--     overrides afterwards: re-sourcing a colourscheme (which the file watcher
--     does on every matugen run) clears anything set on top of it.
local A = require("support.assert_util")
local H = require("support.harness")

-- 1. Template: mode-agnostic, and it must carry the mode into 'background'.
local template = H.read("../matugen/templates/nvim-colors.vim")

A.falsy(template:find("%.dark%.hex"),
    "nvim-colors.vim template uses .dark.hex — light mode would render dark colours")
A.falsy(template:find("%.light%.hex"),
    "nvim-colors.vim template uses .light.hex — dark mode would render light colours")
A.truthy(template:find("{{%s*mode%s*}}"),
    "template never renders {{mode}} — 'set background' can't follow light/dark")
A.contains(template, "set background={{mode}}",
    "template must set 'background' from the matugen mode")

-- A colourscheme file that never touches Normal leaves the editor on whatever
-- the previous scheme set, which is what made nvim look unthemed.
for _, group in ipairs({ "Normal", "NormalFloat", "CursorLine", "Pmenu", "Visual" }) do
    A.truthy(template:find("hi " .. group .. "%f[%s]"),
        "template defines no " .. group .. " highlight")
end
A.contains(template, "let g:colors_name",
    "template must set g:colors_name, or :colorscheme can't track it")

-- 2. The generated file is what actually loads; a stale one fails everything
-- below with a confusing error, so check it up front.
local generated = "colors/matugen.vim"
A.truthy(vim.fn.filereadable(H.path(generated)) == 1,
    generated .. " missing — has matugen run since the template changed?")
A.contains(H.read(generated), "let g:colors_name",
    generated .. " is stale (no g:colors_name) — re-run matugen")

-- 3. theme.lua, against real vim state. The repo's nvim/ has to be on the
-- runtimepath for `:colorscheme matugen` to resolve (headless runs with -u NONE).
vim.opt.rtp:prepend(H.root:gsub("/$", ""))

local theme = H.dofile("lua/user/theme.lua")
A.equal(type(theme.setup), "function", "theme.lua must return a module with setup()")

theme.setup()

A.equal(vim.g.colors_name, "matugen", "setup() did not apply the matugen colourscheme")

-- The generated palette is mode-aware, so 'background' must have come from it.
A.truthy(vim.o.background == "dark" or vim.o.background == "light", "background unset")

-- 4. The local overrides. Other configs link to these names (telescope.lua ->
-- CursorLineBg, lualine.lua -> StatusLineNonText), so a rename here silently
-- no-ops there.
local function hl(name)
    return vim.api.nvim_get_hl(0, { name = name, link = false })
end

A.truthy(hl("Normal").bg == nil, "Normal must stay transparent (bg=none)")

for _, group in ipairs({ "FloatBorder", "CursorLineBg", "StatusLineNonText" }) do
    A.truthy(next(hl(group)) ~= nil, "override group " .. group .. " not defined")
end

-- 5. Overrides must survive a re-source, which is the whole point of hanging
-- them off ColorScheme rather than running them once at startup.
local autos = vim.api.nvim_get_autocmds({ event = "ColorScheme" })
A.truthy(#autos > 0, "no ColorScheme autocmd — overrides would be lost on reload")

vim.api.nvim_set_hl(0, "CursorLineBg", {})
theme.reload()

A.truthy(next(hl("CursorLineBg")) ~= nil, "reload() lost the CursorLineBg override")
A.truthy(hl("Normal").bg == nil, "reload() lost the transparent background")

-- 6. The watch on the generated file: what makes a running nvim re-theme with
-- the rest of the desktop instead of needing a restart.
A.truthy(vim.fn.filereadable(theme.colors_path()) == 1,
    "colors_path() does not point at a readable file: " .. tostring(theme.colors_path()))

local handle = theme.watch()
A.truthy(handle ~= nil, "watch() returned no handle")
A.truthy(handle:is_active(), "watch() handle is not active")

-- Re-arming must not leak the previous handle (the watcher re-arms on every
-- event, since a writer that replaces the file leaves the old watch dead).
local second = theme.watch()
A.falsy(handle:is_active(), "watch() left the previous handle running")
A.truthy(second:is_active(), "re-armed watch() handle is not active")

theme.unwatch()
A.falsy(second:is_active(), "unwatch() left the handle running")
