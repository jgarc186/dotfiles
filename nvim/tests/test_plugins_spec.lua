-- Validates the lazy.nvim plugin spec WITHOUT installing or loading any
-- plugin: require('lazy') is mocked to capture the spec table. Guards the
-- regressions an agent is most likely to introduce when editing plugins.lua.
local A = require("support.assert_util")
local H = require("support.harness")

local spec = H.capture_lazy_spec()

A.truthy(type(spec) == "table", "spec must be a table")
A.truthy(#spec >= 10, "expected at least 10 plugins, got " .. #spec)

-- Every entry resolves to an "owner/repo" id, with no duplicates.
local seen = {}
for i, entry in ipairs(spec) do
    local repo
    if type(entry) == "string" then
        repo = entry
    elseif type(entry) == "table" then
        repo = entry[1]
    end
    A.truthy(type(repo) == "string" and repo:match("^[%w%._-]+/[%w%._-]+$"),
        "spec entry " .. i .. " has no valid owner/repo id")
    A.falsy(seen[repo], "duplicate plugin in spec: " .. tostring(repo))
    seen[repo] = true

    -- config, if present, must be a function lazy can call.
    if type(entry) == "table" and entry.config ~= nil then
        A.truthy(type(entry.config) == "function",
            "config for " .. repo .. " must be a function")
    end
end

-- A few load-bearing plugins must stay in the spec.
for _, repo in ipairs({
    "catppuccin/nvim",
    "nvim-telescope/telescope.nvim",
    "neovim/nvim-lspconfig",
    "hrsh7th/nvim-cmp",
    "nvim-treesitter/nvim-treesitter",
}) do
    A.truthy(seen[repo], "expected plugin missing from spec: " .. repo)
end

-- Every `require('user/plugins/X')` referenced in plugins.lua must point at
-- a file that exists — catches a renamed config file whose require wasn't
-- updated.
local src = H.read("lua/user/plugins.lua")
for name in src:gmatch("require%(['\"]user[./]plugins[./]([%w_%-]+)['\"]%)") do
    local rel = "lua/user/plugins/" .. name .. ".lua"
    A.truthy(vim.fn.filereadable(H.path(rel)) == 1,
        "plugins.lua requires missing config file: " .. rel)
end
