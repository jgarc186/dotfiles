local ufo = require('ufo')

vim.o.foldcolumn = '1' -- '0' is not bad
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true

ufo.setup({})

-- Keymaps
vim.keymap.set('n', '<leader>o', ufo.openAllFolds) -- Open all folds
vim.keymap.set('n', '<leader>c', ufo.closeAllFolds) -- Close all folds 
