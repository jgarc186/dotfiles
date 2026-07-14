-- Test harness for the Neovim config. Unlike hypr/ (which has no local
-- Wayland to run against and therefore mocks the `hl` global), Neovim IS
-- present, so these tests load the real config modules inside a real
-- headless Neovim (`nvim -u NONE -l`) and assert on the resulting state.
--
-- Everything here is network-free: plugin *specs* are captured by mocking
-- `require('lazy')`, and plugin *config* files (which need their plugins
-- installed) are only ever compiled, never executed.
local H = {}

-- Resolve the repo's nvim/ root from this file's own path:
--   <root>/tests/support/harness.lua  ->  <root>/
local this = debug.getinfo(1, "S").source:sub(2)
H.root = this:gsub("tests/support/harness%.lua$", "")

function H.path(rel)
    return H.root .. rel
end

-- dofile always re-executes (no require() caching), so each test gets a
-- fresh run of the module against the current vim state.
function H.dofile(rel)
    return dofile(H.path(rel))
end

-- All .lua files under nvim/ (config + tests excluded callers handle),
-- used by the compile-check test.
function H.lua_files(subdir)
    local glob = H.path(subdir) .. "/**/*.lua"
    local list = vim.fn.glob(glob, true, true)
    table.sort(list)
    return list
end

-- Reads a config file's raw text (for static/source-level assertions).
function H.read(rel)
    local lines = vim.fn.readfile(H.path(rel))
    return table.concat(lines, "\n")
end

-- Resolves an <leader>-prefixed lhs the way Neovim stores it, so maparg()
-- lookups match. Leader is whatever vim.g.mapleader currently is.
function H.resolve_leader(lhs)
    local leader = vim.g.mapleader or "\\"
    return (lhs:gsub("<[lL]eader>", leader))
end

-- Returns the mapping table for `lhs` in `mode`, or nil if unmapped.
function H.maparg(lhs, mode)
    local m = vim.fn.maparg(H.resolve_leader(lhs), mode, false, true)
    if type(m) ~= "table" or vim.tbl_isempty(m) then
        return nil
    end
    return m
end

-- Runs plugins.lua with `require('lazy')` mocked so the spec table passed
-- to lazy.setup() is captured without installing or loading any plugin.
-- Also neutralises the lazy.nvim git-clone bootstrap so the test never
-- touches the network regardless of whether lazy is installed.
function H.capture_lazy_spec()
    local captured = {}

    local prev_lazy = package.loaded["lazy"]
    package.loaded["lazy"] = {
        setup = function(spec, opts)
            captured.spec = spec
            captured.opts = opts
        end,
    }

    -- Pretend lazy.nvim is already installed so the bootstrap skips its
    -- `git clone`. Restore afterwards.
    local uv = vim.uv or vim.loop
    local prev_fs_stat = uv.fs_stat
    uv.fs_stat = function(p)
        return { type = "directory" }
    end

    local ok, err = pcall(function()
        H.dofile("lua/user/plugins.lua")
    end)

    uv.fs_stat = prev_fs_stat
    package.loaded["lazy"] = prev_lazy

    if not ok then
        error("dofile(plugins.lua) failed: " .. tostring(err), 2)
    end
    if not captured.spec then
        error("plugins.lua did not call require('lazy').setup(spec)", 2)
    end
    return captured.spec
end

return H
