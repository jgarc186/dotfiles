-- Space is my leader.
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Relesect visual selection after indenting.
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')

-- Maintain the cursor position when yanking a visual selection.
vim.keymap.set('v', 'y', 'myy`y')

-- Paste replace visual selection without copying it.
vim.keymap.set('v', 'p', '"_dP')

-- Easy insetion of a trailing ; or , from inser mode.
vim.keymap.set('i', ';;', '<Esc>A;')
vim.keymap.set('i', ',,', '<Esc>A,')

-- Quickly clear search highlighting.
vim.keymap.set('n', '<leader>k', ':nohlsearch<CR>')

-- Open right and button split
vim.keymap.set('n', '<leader>v', ':vsplit<CR>')
vim.keymap.set('n', '<leader>b', ':split<CR>')

-- move between splits
vim.api.nvim_set_keymap('n', '<leader>j', '<C-w>j', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>k', '<C-w>k', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>l', '<C-w>l', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>h', '<C-w>h', {noremap = true})

-- close current window
vim.keymap.set('n', '<leader>c', ':close<CR>', { noremap = true })

-- Build, and rebuild c# projects
vim.keymap.set('n', '<leader>bb', ':OmniSharpBuild<CR>', { noremap = true })
vim.keymap.set('n', '<leader>br', ':OmniSharpRebuild<CR>', { noremap = true })
