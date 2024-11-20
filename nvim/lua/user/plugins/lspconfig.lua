-- Setup mason to automatically install LSP server
require('mason').setup()
require('mason-lspconfig').setup({ automatic_installation = true })

local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- PHP:
require('lspconfig').intelephense.setup({
    capabilities = capabilities,
    cmd = { 'intelephense', '--stdio' },
    filetypes = { 'php' },
    root_dir = require('lspconfig/util').root_pattern('composer.json', '.git'),
})

-- React, Vue, TS, & JS
require('lspconfig').ts_ls.setup({
    capabilities = capabilities,
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
    cmd = { 'typescript-language-server', '--stdio' },
})
-- @IMPORTANT: Volar is required setup after ts_ls, 
-- need to make sure that @vue/typescript-plugin and Volar of identical versions
require('lspconfig').volar.setup({
    capabilities = capabilities,
    filetypes = {'vue'},
    cmd = { 'vue-language-server', '--stdio' },
})

-- Python language server
require('lspconfig').basedpyright.setup({
    capabilities = capabilities,
})

-- tailwind css Language Server
require('lspconfig').tailwindcss.setup({
    capabilities = capabilities,
})

-- json
require('lspconfig').jsonls.setup({
    capabilities = capabilities,
    settings = {
        json = {
            schemas = require('schemastore').json.schemas()
        }
    }
})

-- C# language server
require('lspconfig').omnisharp.setup {
    capabilities = capabilities,
    cmd = { 
        "dotnet", 
        "~/developer/josegarcia/dotfiles/omnisharp/omnisharp/OmniSharp.exe",
        "--languageserver",
        "--hostPID",
        tostring(vim.fn.getpid())
    },
    root_dir = require('lspconfig.util').root_pattern("*.sln", "*.csproj"),
}

-- mkeymaps
-- goes to the definition
vim.keymap.set('n', '<leader>d', '<cmd>lua vim.lsp.buf.definition()<CR>')

-- show what the defintion of a method
vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>')

-- goes to the implementation
vim.keymap.set('n', '<leader>i', ':Telescope lsp_implementations<CR>')

-- shows all the references
vim.keymap.set('n', '<leader>r', ':Telescope lsp_references<CR>')

