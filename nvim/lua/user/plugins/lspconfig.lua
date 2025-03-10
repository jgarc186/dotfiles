-- Setup mason to automatically install LSP server
require('mason').setup()
require('mason-lspconfig').setup({ automatic_installation = true })

local lsp = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
}

-- PHP:
lsp.intelephense.setup({
    capabilities = capabilities,
    cmd = { 'intelephense', '--stdio' },
    filetypes = { 'php' },
    root_dir = require('lspconfig/util').root_pattern('composer.json', '.git'),
})

-- React, Vue, TS, & JS
lsp.ts_ls.setup({
    capabilities = capabilities,
    init_options = {
        plugins = {
            {
                name = '@vue/typescript-plugin',
                location = '/home/jose-garcia/developer/dotfiles/node_modules/@vue/typescript-plugin',
                languages = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact'} --, 'vue' }
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
        -- "vue"
    },
    cmd = { 'typescript-language-server', '--stdio' },
})
-- @IMPORTANT: Volar is required setup after ts_ls, 
-- need to make sure that @vue/typescript-plugin and Volar of identical versions
lsp.volar.setup({
    capabilities = capabilities,
    filetypes = {'vue'},
    cmd = { 'vue-language-server', '--stdio' },
})

-- Python language server
lsp.basedpyright.setup({
    capabilities = capabilities,
})

-- tailwind css Language Server
lsp.tailwindcss.setup({
    capabilities = capabilities,
})

-- json
lsp.jsonls.setup({
    capabilities = capabilities,
    settings = {
        json = {
            schemas = require('schemastore').json.schemas()
        }
    }
})

-- C# language server
lsp.csharp_ls.setup({
    capabilities = capabilities,
    cmd = {
        'omnisharp',
        '--languageserver',
        '--hostPID',
        tostring(vim.fn.getpid()),
        '--dotnet:useGlobalMono=true',
        '--msbuild:useBundledMSBuild=true',
    },
    root_dir = require('lspconfig/util').root_pattern('*.sln', '*.csproj') or vim.fn.getcwd(),
    filetypes = { 'cs' },
    autostart = true,
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


