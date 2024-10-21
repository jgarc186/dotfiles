-- Setup mason to automatically install LSP server
require('mason').setup()
require('mason-lspconfig').setup({ automatic_installation = true })

-- PHP:
require('lspconfig').intelephense.setup({})

-- React, Vue, TS, & JS
require('lspconfig').ts_ls.setup({
    init_options = {
        plugins = {
            {
                name = '@vue/typescript-plugin',
                location = '/home/jose-garcia/developer/josegarcia/dotfiles/node_modules/@vue/typescript-plugin',
                languages = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'vue' }
            }
        }
    },
    filetypes = { 
        "javascript", 
        "javascriptreact", 
        "javascript.jsx", 
        "typescript", 
        "typescriptreact", 
        "typescript.tsx",
        "vue"
    },
    cmd = { 'typescript-language-server', '--stdio' }
})
-- @IMPORTANT: Volar is required setup after ts_ls, 
-- need to make sure that @vue/typescript-plugin and Volar of identical versions
require('lspconfig').volar.setup({
    filetypes = {'vue'},
    cmd = { 'vue-language-server', '--stdio' }
})

-- Python language server
require('lspconfig').basedpyright.setup({})

-- tailwind css Language Server
require('lspconfig').tailwindcss.setup({})

-- C# Language server
require('lspconfig').omnisharp.setup({
    cmd = { 'omnisharp', '--languageserver' },
    filetypes = { 'cs', 'vb' },
    root_dir = require('lspconfig/util').root_pattern('*.sln', '*.csproj', '*.fsproj'),
})

-- mkeymaps
-- goes to the definition
vim.keymap.set('n', '<leader>d', '<cmd>lua vim.lsp.buf.definition()<CR>')

-- show what the defintion of a method
vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>')

-- goes to the implementation
vim.keymap.set('n', '<leader>i', ':Telescope lsp_implementations<CR>')

-- shows all the references
vim.keymap.set('n', '<leader>r', ':Telescope lsp_references<CR>')

