vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.wildmode = 'longest:full,full' -- complet the longest common match, then list all matches
vim.opt.completeopt = 'menuone,longest,preview'

vim.opt.title = true
vim.opt.mouse = 'a'

vim.opt.termguicolors = true

vim.opt.spell = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.list = true
vim.opt.listchars = { tab = '- ', trail = '.' }
vim.opt.fillchars:append({ eob = ' ' })

vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

vim.opt.clipboard = 'unnamedplus'

vim.opt.confirm = true

vim.opt.signcolumn = 'yes:1'

vim.opt.undofile = true
vim.opt.backup = true
vim.opt.backupdir:remove('.')

-- Disabled due to a tmux 3.7a bug: tmux doesn't reliably flush Nvim's
-- synchronized-output (DECSET 2026) requests, causing panes to render
-- stale/dark until an external repaint (e.g. switching panes) forces
-- a full redraw. Re-evaluate if/when tmux ships a fix.
-- https://github.com/tmux/tmux/pull/4744
vim.opt.termsync = false

