-- Loads lua/user/keymaps.lua in real Neovim and asserts leader + the
-- resulting keymaps via maparg(), so a dropped or altered binding fails.
local A = require("support.assert_util")
local H = require("support.harness")

H.dofile("lua/user/keymaps.lua")

-- Leader must be set (and set to space) before any <leader> map resolves.
A.equal(vim.g.mapleader, " ", "mapleader must be space")
A.equal(vim.g.maplocalleader, " ", "maplocalleader must be space")

-- Each expected mapping: {mode, lhs, rhs-substring}
local expected = {
    -- visual editing niceties
    { "v", "<",       "gv" },
    { "v", ">",       "gv" },
    { "v", "y",       "myy" },
    { "v", "p",       '"_dP' },
    -- insert-mode trailing punctuation
    { "i", ";;",      ";" },
    { "i", ",,",      "," },
    -- clear search highlight
    { "n", "<leader>n", "nohlsearch" },
    -- window management
    { "n", "<leader>v", "vsplit" },
    { "n", "<leader>b", "split" },
    { "n", "<leader>j", "<C-w>j" },
    { "n", "<leader>l", "<C-w>l" },
    { "n", "<leader>h", "<C-w>h" },
    { "n", "<leader>c", "close" },
    -- C# build shortcuts
    { "n", "<leader>bb", "OmniSharpBuild" },
    { "n", "<leader>br", "OmniSharpRebuild" },
}

for _, m in ipairs(expected) do
    local mode, lhs, want = m[1], m[2], m[3]
    local got = H.maparg(lhs, mode)
    A.truthy(got, "missing mapping " .. mode .. " " .. lhs)
    A.contains(got.rhs or "", want, "rhs for " .. mode .. " " .. lhs)
end

-- <leader>k belongs to the h/j/k/l window-nav group and must NOT be
-- shadowed by anything else (nohlsearch lives on <leader>n now).
local leader_k = H.maparg("<leader>k", "n")
A.truthy(leader_k, "missing mapping n <leader>k")
A.contains(leader_k.rhs or "", "<C-w>k",
    "<leader>k must move to the window above")
A.falsy((leader_k.rhs or ""):find("nohlsearch", 1, true),
    "<leader>k must not be shadowed by nohlsearch again")
