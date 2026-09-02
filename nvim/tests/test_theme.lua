-- Real-state test for the theme wiring (lua/user/theme.lua).
--
-- nvim follows the desktop's light/dark mode with a catppuccin flavour — latte
-- or mocha — rather than the wallpaper palette. The mode comes out of the
-- `set background=` line in the generated colors/matugen.vim, so the checks
-- run in two parts:
--
--   * the generated file has to keep carrying an honest mode. Its template can
--     silently pin one (`.dark.hex`, the bug it shipped with), which would
--     leave the editor a mode behind the rest of the desktop.
--   * theme.lua has to map that mode to a flavour, apply it, and re-apply the
--     local overrides afterwards: applying a colourscheme (which the file
--     watcher does on every matugen run) clears anything set on top of it.
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
-- runtimepath for the fallback `:colorscheme matugen` to resolve, and the
-- plugin dir for the catppuccin flavours (headless runs with -u NONE).
vim.opt.rtp:prepend(H.root:gsub("/$", ""))

local catppuccin = vim.fn.stdpath("data") .. "/lazy/catppuccin"
local have_catppuccin = vim.fn.isdirectory(catppuccin) == 1
if have_catppuccin then
    vim.opt.rtp:prepend(catppuccin)
end

local theme = H.dofile("lua/user/theme.lua")
A.equal(type(theme.setup), "function", "theme.lua must return a module with setup()")

-- The mode has to come from the generated file, not from vim.o.background:
-- that is the value the watcher fires on, and the one the desktop shares.
local file_mode = H.read(generated):match("set background=(%a+)")
A.equal(theme.mode(), file_mode, "mode() disagrees with " .. generated)
A.equal(theme.flavours.light, "catppuccin-latte", "light mode must use latte")
A.equal(theme.flavours.dark, "catppuccin-mocha", "dark mode must use mocha")
A.equal(theme.flavour(), theme.flavours[file_mode],
    "flavour() does not follow the generated mode")

theme.setup()

if have_catppuccin then
    A.equal(vim.g.colors_name, theme.flavours[file_mode],
        "setup() did not apply the flavour for " .. file_mode .. " mode")
else
    -- Without the plugin installed, reload() must still land on something.
    A.equal(vim.g.colors_name, "matugen",
        "setup() did not fall back to the generated colourscheme")
end

A.truthy(vim.o.background == file_mode,
    "'background' is " .. vim.o.background .. ", expected " .. file_mode)

-- 4. The local overrides. Other configs link to these names (telescope.lua ->
-- CursorLineBg, lualine.lua -> StatusLineNonText), so a rename here silently
-- no-ops there.
local function hl(name)
    return vim.api.nvim_get_hl(0, { name = name, link = false })
end

A.truthy(hl("Normal").bg == nil, "Normal must stay transparent (bg=none)")
-- nvim_set_hl replaces a group outright, so clearing the background is where
-- the flavour's text colour gets dropped by accident.
A.truthy(hl("Normal").fg ~= nil, "Normal lost its foreground when bg was cleared")

for _, group in ipairs({ "FloatBorder", "CursorLineBg", "StatusLineNonText" }) do
    A.truthy(next(hl(group)) ~= nil, "override group " .. group .. " not defined")
end

-- catppuccin gives the tree an opaque background, which paints a slab over the
-- transparent editor whenever the tree is open — the exact symptom that made
-- an old session look half-dark.
for _, group in ipairs({ "NvimTreeNormal", "NvimTreeNormalNC" }) do
    A.truthy(hl(group).bg == nil, group .. " must be transparent, not opaque")
end

-- 5. Overrides must survive a re-source, which is the whole point of hanging
-- them off ColorScheme rather than running them once at startup.
local autos = vim.api.nvim_get_autocmds({ event = "ColorScheme" })
A.truthy(#autos > 0, "no ColorScheme autocmd — overrides would be lost on reload")

vim.api.nvim_set_hl(0, "CursorLineBg", {})
theme.reload()

A.truthy(next(hl("CursorLineBg")) ~= nil, "reload() lost the CursorLineBg override")
A.truthy(hl("Normal").bg == nil, "reload() lost the transparent background")

-- 6. Contrast. Normal is transparent, so syntax is read against the terminal's
-- background, which matugen themes to the same surface it writes into the
-- generated colourscheme. A flavour on the wrong side of the mode (mocha over
-- a light terminal) fails here, which is the failure this section is for.
local function luminance(rgb)
    local function channel(c)
        c = c / 255
        return c <= 0.03928 and c / 12.92 or ((c + 0.055) / 1.055) ^ 2.4
    end
    local r = channel(math.floor(rgb / 65536) % 256)
    local g = channel(math.floor(rgb / 256) % 256)
    local b = channel(rgb % 256)
    return 0.2126 * r + 0.7152 * g + 0.0722 * b
end

local function contrast(fg, bg)
    local l1, l2 = luminance(fg), luminance(bg)
    if l1 < l2 then
        l1, l2 = l2, l1
    end
    return (l1 + 0.05) / (l2 + 0.05)
end

-- Normal's background is cleared by the overrides, so take the colourscheme's
-- own surface colour from the generated file — that is what the terminal
-- underneath is themed to as well.
local surface = H.read(generated):match("hi Normal%s+guibg=(#%x%x%x%x%x%x)")
A.truthy(surface, "no 'hi Normal guibg=' in " .. generated)
local surface_rgb = tonumber(surface:sub(2), 16)

-- A tripwire for the flavour being on the wrong side of the mode, not an audit
-- of catppuccin's palette: mocha's text over a light terminal measures about
-- 1.2:1, while latte's own paler accents sit as low as 2.8:1 by design. The
-- floor is set below catppuccin and far above a mismatch.
local MIN_CONTRAST = 2.0

-- Comment is left out on purpose: catppuccin draws it at roughly 2.5:1 in
-- both flavours, and its own design call is not ours to override. The Diff*
-- groups are out because catppuccin tints them by background, with no
-- foreground to measure.
for _, group in ipairs({
    "Identifier", "Constant", "Type", "String", "Special", "Function",
    "Statement", "Keyword", "Delimiter", "Operator",
    "DiagnosticError", "DiagnosticWarn", "DiagnosticHint",
}) do
    local fg = hl(group).fg
    A.truthy(fg, group .. " sets no foreground")
    local ratio = contrast(fg, surface_rgb)
    A.truthy(ratio >= MIN_CONTRAST, string.format(
        "%s is illegible in %s mode: contrast %.2f:1 against %s (need %.1f:1)",
        group, vim.o.background, ratio, surface, MIN_CONTRAST))
end

-- 7. The watch on the generated file: what makes a running nvim re-theme with
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
