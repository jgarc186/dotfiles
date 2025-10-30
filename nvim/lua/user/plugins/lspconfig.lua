-- Setup mason to automatically install LSP server
require('mason').setup()
require('mason-lspconfig').setup({ 
  automatic_installation = true,
  handlers = {
    function(server_name)
      -- Skip servers we're configuring manually
      if server_name == "vtsls" or server_name == "vue_ls" or server_name == "volar" then
        return
      end
      require('lspconfig')[server_name].setup({})
    end,
  }
})

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
-- vtsls handles TypeScript in Vue files
local vtsls_config = {
  capabilities = capabilities,
  settings = {
    vtsls = {
      tsserver = {
        globalPlugins = {
          {
            name = '@vue/typescript-plugin',
            location = '/Users/josegarcia/developer/dotfiles/node_modules/@vue/typescript-plugin',
            languages = { 'vue' },
          },
        },
      },
    },
  },
  filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
}

lsp.vtsls.setup(vtsls_config)

-- Volar handles Vue-specific features (components, templates, etc)
lsp.vue_ls.setup({
  capabilities = capabilities,
  cmd = { 
    'node', 
    '/Users/josegarcia/developer/dotfiles/node_modules/@vue/language-server/bin/vue-language-server.js', 
    '--stdio' 
  },
  filetypes = { 'vue' },
  init_options = {
    vue = {
      hybridMode = true,
    },
    typescript = {
      tsdk = '/Users/josegarcia/developer/dotfiles/node_modules/typescript/lib'
    },
  },
})

-- Python language server
lsp.basedpyright.setup({
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
lsp.omnisharp.setup({
    capabilities = capabilities,
    cmd = {
        '/home/jose/developer/dotfiles/omnisharp/omnisharp/OmniSharp.exe',
        -- '/usr/bin/omnisharp',
        '--languageserver',
        '--hostPID',
        tostring(vim.fn.getpid()),
        '--dotnet:useGlobalMono=true',
        '--msbuild:useBundledMSBuild=true',
    },
    root_dir = require('lspconfig.util').root_pattern('*.sln', '*.csproj') or vim.fn.getcwd(),
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
