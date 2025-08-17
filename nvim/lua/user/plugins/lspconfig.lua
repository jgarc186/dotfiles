-- Setup mason to automatically install LSP server
require('mason').setup()
require('mason-lspconfig').setup({ automatic_installation = true })

local lsp = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()
local vue_language_server_path = '~/developer/dotfiles/node_modules/@vue/typescript-plugin'
local vue_plugin = {
  name = '@vue/typescript-plugin',
  location = vue_language_server_path,
  languages = { 'vue' },
  configNamespace = 'typescript',
}

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

-- Single LSP for TypeScript + Vue with better performance
lsp.vtsls.setup({
  capabilities = capabilities,
  settings = {
  vtsls = {
    tsserver = {
      globalPlugins = {
        vue_plugin,
      },
    },
    -- Add these for better Vue experience
    experimental = {
      completion = {
        enableServerSideFuzzyMatch = true,
       },
      },
    },
  },
  typescript = {
    preferences = {
      -- Better import paths for Vue components
      importModuleSpecifier = "relative",
      includePackageJsonAutoImports = "auto",
    },
    suggest = {
      autoImports = true,
    },
  },
  filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
})

lsp.vue_ls.setup({
  capabilities = capabilities,
  settings = {
    vue = {
      hybridMode = true,
      completion = {
        autoImport = true,
        tagCasing = "kebab", -- or "pascal" based on your preference
      },
      validation = {
        template = true,
        style = true,
        script = true,
      },
    },
  },
  on_init = function(client)
    client.handlers['tsserver/request'] = function(_, result, context)
      local ts_clients = vim.lsp.get_clients({ bufnr = context.bufnr, name = 'ts_ls' })
      local vtsls_clients = vim.lsp.get_clients({ bufnr = context.bufnr, name = 'vtsls' })
      local clients = {}

      vim.list_extend(clients, ts_clients)
      vim.list_extend(clients, vtsls_clients)

      if #clients == 0 then
        vim.notify('Could not find `vtsls` or `ts_ls` lsp client, `vue_ls` would not work without it.', vim.log.levels.ERROR)
        return
      end
      local ts_client = clients[1]

      local param = unpack(result)
      local id, command, payload = unpack(param)
      ts_client:exec_cmd({
        title = 'vue_request_forward', -- You can give title anything as it's used to represent a command in the UI, `:h Client:exec_cmd`
        command = 'typescript.tsserverRequest',
        arguments = {
          command,
          payload,
        },
      }, { bufnr = context.bufnr }, function(_, r)
          local response = r and r.body
          -- TODO: handle error or response nil here, e.g. logging
          -- NOTE: Do NOT return if there's an error or no response, just return nil back to the vue_ls to prevent memory leak
          local response_data = { { id, response } }

          --- @diagnostic disable-next-line: param-type-mismatch
          client:notify('tsserver/response', response_data)
        end)
    end
  end,
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


