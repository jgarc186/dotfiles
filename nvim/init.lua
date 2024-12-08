require('user/plugins')
require('user/options')
require('user/keymaps')

-- Auto format C# files on save
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.cs",
    callback = function()
        vim.lsp.buf.format({ async = false })
    end,
})
