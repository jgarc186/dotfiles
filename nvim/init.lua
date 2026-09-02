require('user/plugins')
require('user/options')

-- Colours come from matugen, shared with the rest of the desktop; this also
-- watches the generated palette so a light/dark switch reaches a running nvim.
require('user/theme').setup()

vim.o.termsync = false

-- Auto format on save
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = { "*.cs", "*.js", "*.ts", "*.jsx", "*.tsx", "*.vue", "*.json", "*.php" },
    callback = function()
        vim.lsp.buf.format({ async = false })
    end,
})
