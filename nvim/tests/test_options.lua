-- Loads lua/user/options.lua in real Neovim and asserts the resulting
-- option values. Catches typos, wrong values, and deprecated options
-- (a removed option raises on assignment -> the dofile itself fails).
local A = require("support.assert_util")
local H = require("support.harness")

H.dofile("lua/user/options.lua")

local function opt(name)
    return vim.api.nvim_get_option_value(name, {})
end

-- Indentation
A.equal(opt("expandtab"), true, "expandtab")
A.equal(opt("shiftwidth"), 4, "shiftwidth")
A.equal(opt("tabstop"), 4, "tabstop")
A.equal(opt("softtabstop"), 4, "softtabstop")
A.equal(opt("smartindent"), true, "smartindent")

-- Display
A.equal(opt("wrap"), false, "wrap")
A.equal(opt("number"), true, "number")
A.equal(opt("relativenumber"), true, "relativenumber")
A.equal(opt("title"), true, "title")
A.equal(opt("termguicolors"), true, "termguicolors")
A.equal(opt("signcolumn"), "yes:1", "signcolumn")
A.equal(opt("scrolloff"), 8, "scrolloff")
A.equal(opt("sidescrolloff"), 8, "sidescrolloff")

-- Completion
A.equal(opt("wildmode"), "longest:full,full", "wildmode")
A.equal(opt("completeopt"), "menuone,longest,preview", "completeopt")

-- Search
A.equal(opt("ignorecase"), true, "ignorecase")
A.equal(opt("smartcase"), true, "smartcase")

-- Splits
A.equal(opt("splitbelow"), true, "splitbelow")
A.equal(opt("splitright"), true, "splitright")

-- Editing / files
A.equal(opt("mouse"), "a", "mouse")
A.equal(opt("spell"), true, "spell")
A.equal(opt("clipboard"), "unnamedplus", "clipboard")
A.equal(opt("confirm"), true, "confirm")
A.equal(opt("undofile"), true, "undofile")
A.equal(opt("backup"), true, "backup")

-- listchars: tab -> '- ', trail -> '.'
A.contains(opt("listchars"), "tab:- ", "listchars tab")
A.contains(opt("listchars"), "trail:.", "listchars trail")

-- Intentionally off: DECSET 2026 sync disabled for the tmux 3.7a bug.
-- If an agent flips this back on, this fails and points at the comment.
A.equal(opt("termsync"), false, "termsync must stay false (tmux 3.7a bug)")
