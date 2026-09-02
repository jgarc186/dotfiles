-- Loads init.lua with its two require()s stubbed (so no plugin bootstrap /
-- network) and asserts the format-on-save autocmd it registers.
local A = require("support.assert_util")
local H = require("support.harness")

-- Neutralise the entry requires; we only want init.lua's own side effects
-- (the BufWritePre autocmd and the termsync guard). theme is stubbed with a
-- table rather than `true` because init.lua calls setup() on it.
package.loaded["user/plugins"] = true
package.loaded["user/options"] = true

local theme_setup_calls = 0
package.loaded["user/theme"] = {
    setup = function() theme_setup_calls = theme_setup_calls + 1 end,
}

H.dofile("init.lua")

-- The matugen colourscheme and its file watch are wired up from here; without
-- this call nvim keeps whatever colours a plugin happened to set.
A.equal(theme_setup_calls, 1, "init.lua did not call require('user/theme').setup()")

-- init.lua also re-asserts the tmux workaround.
A.equal(vim.api.nvim_get_option_value("termsync", {}), false, "termsync")

local autos = vim.api.nvim_get_autocmds({ event = "BufWritePre" })
A.truthy(#autos > 0, "no BufWritePre autocmd registered")

-- Collect the patterns covered by BufWritePre autocmds.
local patterns = {}
for _, a in ipairs(autos) do
    patterns[a.pattern] = true
end

-- Format-on-save must cover these filetypes.
for _, p in ipairs({ "*.cs", "*.js", "*.ts", "*.jsx", "*.tsx", "*.vue", "*.json", "*.php" }) do
    A.truthy(patterns[p], "format-on-save missing pattern " .. p)
end
