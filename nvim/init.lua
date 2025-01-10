require('user/plugins')
require('user/options')
require('user/keymaps')

-- Auto format C# files on save
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.cs, *.js, *.ts, *.jsx, *.tsx, *.vue, *.json, *.php",
    callback = function()
        vim.lsp.buf.format({ async = true })
    end,
})
