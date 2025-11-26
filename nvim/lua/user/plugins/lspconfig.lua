-- Setup mason to automatically install LSP server
require('mason').setup()
require('mason-lspconfig').setup({ 
  automatic_installation = true,
  handlers = {
    function(server_name)
      -- Skip servers we're configuring manually
      if server_name == "vtsls" or server_name == "volar" then
        return
      end
      
      -- Use native API if available, fallback to lspconfig
      if vim.fn.has('nvim-0.11') == 1 then
        vim.lsp.config(server_name, {})
      else
        require('lspconfig')[server_name].setup({})
      end
    end,
  }
})

local capabilities = require('cmp_nvim_lsp').default_capabilities()

capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
}

-- Helper function to setup LSP with both old and new API
local function setup_lsp(server_name, config)
  config.capabilities = capabilities
  
  if vim.fn.has('nvim-0.11') == 1 then
    -- Use native vim.lsp.config for Neovim 0.11+
    vim.lsp.config(server_name, config)
  else
    -- Fallback to lspconfig for older versions
    require('lspconfig')[server_name].setup(config)
  end
end

-- PHP
setup_lsp('intelephense', {
    cmd = { 'intelephense', '--stdio' },
    filetypes = { 'php' },
    root_markers = { 'composer.json', '.git' },
})

-- vtsls handles TypeScript in Vue files
setup_lsp('vtsls', {
  settings = {
    vtsls = {
      tsserver = {
        globalPlugins = {
          {
            name = '@vue/typescript-plugin',
            location = '/home/jose/developer/dotfiles/node_modules/@vue/typescript-plugin',
            languages = { 'vue' },
          },
        },
      },
    },
  },
  filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
})

-- Volar handles Vue-specific features (components, templates, etc)
-- Note: vue_ls is deprecated, but keeping your setup with volar name
setup_lsp('volar', {
  cmd = { 
    'node', 
    '/home/jose/developer/dotfiles/node_modules/@vue/language-server/bin/vue-language-server.js', 
    '--stdio' 
  },
  filetypes = { 'vue' },
  init_options = {
    vue = {
      hybridMode = true,
    },
    typescript = {
      tsdk = '/home/jose/developer/dotfiles/node_modules/typescript/lib'
    },
  },
})

-- Python language server
setup_lsp('basedpyright', {})

-- JSON
setup_lsp('jsonls', {
    settings = {
        json = {
            schemas = require('schemastore').json.schemas()
        }
    }
})

-- C# language server
setup_lsp('omnisharp', {
    cmd = {
        '/home/jose/developer/dotfiles/omnisharp/omnisharp/OmniSharp.exe',
        '--languageserver',
        '--hostPID',
        tostring(vim.fn.getpid()),
        '--dotnet:useGlobalMono=true',
        '--msbuild:useBundledMSBuild=true',
    },
    root_markers = { '*.sln', '*.csproj' },
    filetypes = { 'cs' },
    autostart = true,
})

-- Enable LSP on appropriate filetypes for Neovim 0.11+
if vim.fn.has('nvim-0.11') == 1 then
  vim.api.nvim_create_autocmd('FileType', {
    pattern = '*',
    callback = function(args)
      vim.lsp.enable({
        'intelephense',
        'vtsls', 
        'volar',
        'basedpyright',
        'jsonls',
        'omnisharp',
      }, args.buf)
    end,
  })
end

-- Keymaps
-- goes to the definition
vim.keymap.set('n', '<leader>d', '<cmd>lua vim.lsp.buf.definition()<CR>')

-- show what the definition of a method
vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>')

-- goes to the implementation
vim.keymap.set('n', '<leader>i', ':Telescope lsp_implementations<CR>')

-- shows all the references
vim.keymap.set('n', '<leader>r', ':Telescope lsp_references<CR>')
