-- Keeps nvim's colourscheme in step with the desktop's light/dark mode.
--
-- The scheme itself is catppuccin — latte in light mode, mocha in dark. A
-- wallpaper-derived syntax palette was tried first and reads badly: a matugen
-- palette carries four hues, and on a low-saturation wallpaper the syntax
-- categories collapse into near-identical tones. Everything else on this
-- desktop still follows the wallpaper; nvim follows only the mode.
--
-- The mode is read from colors/matugen.vim, which matugen regenerates on every
-- `matugen image` / `theme-mode` run with a `set background=<mode>` line. That
-- file is also still a working colourscheme, used as the fallback when
-- catppuccin isn't installed yet.
--
-- Most apps re-theme through a post_hook in matugen/config.toml; nvim has no
-- signal to reload a colourscheme, so it watches that file instead. That also
-- catches a `matugen image` run by hand, which no hook of ours would see.
--
-- Two ordering facts drive the shape of this file:
--   * applying a colourscheme clears everything set on top of it, so the local
--     overrides hang off ColorScheme rather than running once at startup.
--   * a writer that replaces the file instead of truncating it leaves the watch
--     pointing at a dead inode, so the watch re-arms after every event.
local M = {}

-- The generated colourscheme: the mode signal, and the fallback scheme.
M.name = "matugen"

M.flavours = {
    light = "catppuccin-latte",
    dark = "catppuccin-mocha",
}

-- Resolved through the ~/.config/nvim symlink: the watch has to land on the
-- file in the dotfiles repo that matugen actually rewrites, not on the link.
function M.colors_path()
    local uv = vim.uv or vim.loop
    local path = vim.fn.stdpath("config") .. "/colors/" .. M.name .. ".vim"
    return uv.fs_realpath(path) or path
end

-- Whichever mode matugen last ran in, straight out of the generated file.
-- Reading the file rather than `vim.o.background` keeps this honest when a
-- plugin has changed 'background' on its own, and it is the same value the
-- watch fires on. Defaults to dark, matching matugen's own default.
function M.mode()
    local file = io.open(M.colors_path(), "r")
    if not file then
        return "dark"
    end

    local mode
    for line in file:lines() do
        mode = line:match("^%s*set%s+background=(%a+)")
        if mode then
            break
        end
    end
    file:close()

    return (mode == "light" or mode == "dark") and mode or "dark"
end

function M.flavour()
    return M.flavours[M.mode()]
end

-- Local tweaks over the colourscheme. The three derived groups exist because
-- other configs link to them: telescope.lua -> CursorLineBg, lualine.lua ->
-- StatusLineNonText.
function M.overrides()
    local function bg_of(group)
        return vim.api.nvim_get_hl(0, { name = group, link = false }).bg
    end
    local function fg_of(group)
        return vim.api.nvim_get_hl(0, { name = group, link = false }).fg
    end

    -- Transparent, so the terminal shows through — kitty and ghostty are
    -- matugen-themed too, which is what makes the seam invisible. The
    -- foreground is carried over explicitly: nvim_set_hl replaces a group
    -- outright, so clearing the background alone would drop the flavour's text
    -- colour and leave the editor on the terminal's default foreground.
    vim.api.nvim_set_hl(0, "Normal", { fg = fg_of("Normal"), bg = "none" })
    vim.api.nvim_set_hl(0, "NormalNC", { fg = fg_of("NormalNC"), bg = "none" })

    -- catppuccin gives the tree an opaque background of its own, which paints
    -- a solid slab over the transparent editor whenever the tree is open.
    for _, group in ipairs({ "NvimTreeNormal", "NvimTreeNormalNC", "NvimTreeEndOfBuffer" }) do
        vim.api.nvim_set_hl(0, group, { fg = fg_of(group), bg = "none" })
    end

    -- Borderless floats: border drawn in the float's own background colour.
    local float_bg = bg_of("NormalFloat")
    vim.api.nvim_set_hl(0, "FloatBorder", { fg = float_bg, bg = float_bg })

    -- Invisible cursorline-coloured fill, used as a border colour by pickers.
    local line_bg = bg_of("CursorLine")
    vim.api.nvim_set_hl(0, "CursorLineBg", { fg = line_bg, bg = line_bg })

    vim.api.nvim_set_hl(0, "StatusLineNonText", {
        fg = fg_of("NonText"),
        bg = bg_of("StatusLine"),
    })
end

-- Applies the flavour for the current mode; the ColorScheme autocmd re-runs
-- the overrides afterwards. Falls back to the generated matugen colourscheme,
-- which is always present, when catppuccin isn't installed yet.
function M.reload()
    local scheme = M.flavour()

    if pcall(vim.cmd.colorscheme, scheme) then
        return true
    end

    if pcall(vim.cmd.colorscheme, M.name) then
        vim.notify(scheme .. " is not installed; using the generated "
            .. M.name .. " colourscheme", vim.log.levels.WARN)
        return true
    end

    vim.notify("no colourscheme could be loaded (" .. scheme .. ", " .. M.name .. ")",
        vim.log.levels.WARN)
    return false
end

local watcher, pending

function M.unwatch()
    if watcher then
        watcher:stop()
        if not watcher:is_closing() then
            watcher:close()
        end
        watcher = nil
    end
end

function M.watch()
    M.unwatch()

    local uv = vim.uv or vim.loop
    watcher = uv.new_fs_event()
    if not watcher then
        return nil
    end

    local ok = watcher:start(M.colors_path(), {}, function(err)
        if err or pending then
            return
        end
        -- matugen writes the file in several chunks; debounce so the mode is
        -- read once, off the finished file.
        pending = true
        vim.schedule(function()
            vim.defer_fn(function()
                pending = nil
                M.reload()
                M.watch()
            end, 50)
        end)
    end)

    if not ok then
        M.unwatch()
        return nil
    end

    return watcher
end

function M.setup()
    -- Pattern '*', not one scheme name: the flavour applied changes with the
    -- mode, and the fallback is a different scheme again.
    vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("matugen_theme", { clear = true }),
        pattern = "*",
        callback = M.overrides,
    })

    M.reload()
    M.watch()
    return M
end

return M
