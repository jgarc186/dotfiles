-- Setup mason to automatically install LSP server
require('mason').setup()
require('mason-lspconfig').setup({ automatic_installation = true })


-- PHP:
require('lspconfig').intelephense.setup({})

-- React, Vue, TS, & JS
-- require('lspconfig').volar.setup({
--    filetypes = { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact', 'vue' }
-- })
require('lspconfig').tsserver.setup({
    filetypes = {
        'typescript',
        'typescriptreact',
        'typescript.tsx',
    },
    cmd = { 'typescript-language-server', '--stdio' }
})

require('lspconfig').vuels.setup({})

require('lspconfig').tailwindcss.setup({})

-- mkeymaps
vim.keymap.set('n', '<leader>d', '<cmd>lua vim.lsp.buf.definition()<CR>')
