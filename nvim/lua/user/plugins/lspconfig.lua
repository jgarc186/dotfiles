-- Setup mason to automatically install LSP server
require('mason').setup()
require('mason-lspconfig').setup({
  automatic_installation = true,
  -- mason-lspconfig automatically calls vim.lsp.enable() for installed servers.
  -- Exclude vue_ls since we configure volar manually for hybrid mode.
  automatic_enable = {
    exclude = { 'vue_ls', 'vtsls' },
  },
})

local home = vim.fn.expand('~')
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
            location = home .. '/developer/dotfiles/node_modules/@vue/typescript-plugin',
            languages = { 'vue' },
          },
        },
      },
    },
  },
  filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
  root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
})

-- Volar handles Vue-specific features (components, templates, etc)
setup_lsp('volar', {
  cmd = {
    'node',
    home .. '/developer/dotfiles/node_modules/@vue/language-server/bin/vue-language-server.js',
    '--stdio'
  },
  filetypes = { 'vue' },
  root_markers = { 'package.json', '.git' },
  init_options = {
    vue = {
      hybridMode = true,
    },
    typescript = {
      tsdk = home .. '/developer/dotfiles/node_modules/typescript/lib'
    },
  },
})

-- Python language server
setup_lsp('basedpyright', {
    cmd = { 'basedpyright-langserver', '--stdio' },
    filetypes = { 'python' },
    root_markers = { 'pyproject.toml', 'setup.py', 'pyrightconfig.json', '.git' },
})

-- JSON
setup_lsp('jsonls', {
    cmd = { 'vscode-json-language-server', '--stdio' },
    filetypes = { 'json', 'jsonc' },
    root_markers = { '.git' },
    settings = {
        json = {
            schemas = require('schemastore').json.schemas()
        }
    }
})

-- C# language server
setup_lsp('omnisharp', {
    cmd = {
        home .. '/developer/dotfiles/omnisharp/omnisharp/OmniSharp.exe',
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


-- Manually enable servers excluded from mason-lspconfig's automatic_enable
vim.lsp.enable('vtsls')

-- Stop LSP servers when their last attached buffer is closed
vim.api.nvim_create_autocmd('LspDetach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then return end
    vim.schedule(function()
      if vim.tbl_isempty(client.attached_buffers) then
        client:stop()
      end
    end)
  end,
})

-- Keymaps
-- goes to the definition
vim.keymap.set('n', '<leader>d', '<cmd>lua vim.lsp.buf.definition()<CR>')

-- show what the definition of a method
vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>')

-- goes to the implementation
vim.keymap.set('n', '<leader>i', ':Telescope lsp_implementations<CR>')

-- shows all the references
vim.keymap.set('n', '<leader>r', ':Telescope lsp_references<CR>')
