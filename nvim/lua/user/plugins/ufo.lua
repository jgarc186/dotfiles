local ufo = require('ufo')

vim.o.foldcolumn = '1' -- '0' is not bad
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true

ufo.setup({
    -- Kaymaps
    vim.keymap.set('n', '<leader>o', require('ufo').openAllFolds),
    vim.keymap.set('n', '<leader>c', require('ufo').closeAllFolds)
})


