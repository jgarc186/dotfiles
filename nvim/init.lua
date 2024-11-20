require('user/plugins')
require('user/options')
require('user/keymaps')

-- Automatically source options.lua on BufEnter
vim.api.nvim_create_autocmd('BufEnter', {
    pattern = '*',
    command = 'source ~/developer/josegarcia/dotfiles/nvim/lua/user/options.lua'
})

-- Auto format C# files on save
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.cs",
    callback = function()
        vim.lsp.buf.format({ async = false })
        -- once we format the file on save, we need to reload the file to see the changes and persist them
        vim.cmd('e')
    end,
})
