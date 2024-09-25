-- Setup mason to automatically install LSP server
require('mason').setup()
require('mason-lspconfig').setup({ automatic_installation = true })

-- PHP:
require('lspconfig').intelephense.setup({})

-- React, Vue, TS, & JS
require('lspconfig').tsserver.setup({
    filetypes = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact', 'jsx', 'tsx' },
    cmd = { 'typescript-language-server', '--stdio' }
})
require('lspconfig').volar.setup({
    filetypes = {'vue'},
    cmd = { 'vue-language-server', '--stdio' }
})

-- Python language server
require('lspconfig').basedpyright.setup({})

-- Ruby Language server
require('lspconfig').ruby_lsp.setup({})

-- tailwind css Language Server
require('lspconfig').tailwindcss.setup({})

-- mkeymaps
-- goes to the definition
vim.keymap.set('n', '<leader>d', '<cmd>lua vim.lsp.buf.definition()<CR>')

-- show what the defintion of a method
vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>')

-- goes to the implementation
vim.keymap.set('n', '<leader>i', ':Telescope lsp_implementations<CR>')

-- shows all the references
vim.keymap.set('n', '<leader>r', ':Telescope lsp_references<CR>')

