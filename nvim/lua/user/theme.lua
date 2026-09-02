-- Keeps nvim on the desktop-wide matugen palette.
--
-- matugen (see matugen/config.toml) regenerates a colour file per app on every
-- `matugen image` / `theme-mode` run, including the light/dark toggle in the
-- quickshell bar. nvim's is colors/matugen.vim. Most apps reload through a
-- post_hook — nvim has no signal to reload a colourscheme, so it watches the
-- generated file itself. That also covers a `matugen image` run by hand, which
-- no hook of ours would see.
--
-- Two ordering facts drive the shape of this file:
--   * re-sourcing a colourscheme clears everything set on top of it, so the
--     local overrides hang off ColorScheme rather than running once at startup.
--   * a writer that replaces the file instead of truncating it leaves the watch
--     pointing at a dead inode, so the watch re-arms after every event.
local M = {}

M.name = "matugen"

-- Resolved through the ~/.config/nvim symlink: the watch has to land on the
-- file in the dotfiles repo that matugen actually rewrites, not on the link.
function M.colors_path()
    local uv = vim.uv or vim.loop
    local path = vim.fn.stdpath("config") .. "/colors/" .. M.name .. ".vim"
    return uv.fs_realpath(path) or path
end

-- Local tweaks over the generated palette. The three derived groups exist
-- because other configs link to them: telescope.lua -> CursorLineBg,
-- lualine.lua -> StatusLineNonText.
function M.overrides()
    local function bg_of(group)
        return vim.api.nvim_get_hl(0, { name = group, link = false }).bg
    end
    local function fg_of(group)
        return vim.api.nvim_get_hl(0, { name = group, link = false }).fg
    end

    -- Transparent, so the terminal shows through — kitty and ghostty are
    -- matugen-themed too, which is what makes the seam invisible.
    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })

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

-- Applies the colourscheme; the ColorScheme autocmd re-runs the overrides.
function M.reload()
    local ok, err = pcall(vim.cmd.colorscheme, M.name)
    if not ok then
        vim.notify("matugen colourscheme failed to load: " .. tostring(err),
            vim.log.levels.WARN)
    end
    return ok
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
        -- matugen writes the file in several chunks; debounce so the
        -- colourscheme is sourced once, against the finished file.
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
    vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("matugen_theme", { clear = true }),
        pattern = M.name,
        callback = M.overrides,
    })

    if not M.reload() then
        -- Fresh clone, before matugen has ever run: catppuccin is still in the
        -- plugin list precisely so there is something to fall back to.
        pcall(vim.cmd.colorscheme, "catppuccin-mocha")
        M.overrides()
    end

    M.watch()
    return M
end

return M
