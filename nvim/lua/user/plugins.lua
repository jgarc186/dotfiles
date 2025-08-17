-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
require('user/keymaps')

-- Setup lazy.nvim
require("lazy").setup({

    -- Themes
    {
        'catppuccin/nvim',
        as = 'catppuccin',
        config = function()
            -- options: latte, frappe, macchiato, mocha
           vim.cmd('colorscheme catppuccin-mocha')

           -- Set the background to transparent
            vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })

            vim.api.nvim_set_hl(0, 'FloatBorder', {
                fg = vim.api.nvim_get_hl_by_name('NormalFloat', true).background,
                bg = vim.api.nvim_get_hl_by_name('NormalFloat', true).background,
            })

            -- Make the cursor line invisible
            vim.api.nvim_set_hl(0, 'CursorLinmeBg', {
                fg = vim.api.nvim_get_hl_by_name('CursorLine', true).background,
                bg = vim.api.nvim_get_hl_by_name('CursorLine', true).background,
            })
            
            vim.api.nvim_set_hl(0, 'StatusLineNonText', {
                fg = vim.api.nvim_get_hl_by_name('NonText', true).foreground,
                bg = vim.api.nvim_get_hl_by_name('StatusLine', true).background,
            })

            vim.api.nvim_set_hl(0, 'NvimTreeIndentMarker', { fg = '#30323E' })
        end,
    },

    -- Github Copilot
    -- 'github/copilot.vim',

    -- Commenting support
    'tpope/vim-commentary',

    -- Fuzzy finder
    {
        'nvim-telescope/telescope.nvim',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'kyazdani42/nvim-web-devicons',
            'nvim-telescope/telescope-live-grep-args.nvim',
            { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
        },
        config = function()
            require('user/plugins/telescope')
        end,
    },

    -- File tree sidebar
    {
        'kyazdani42/nvim-tree.lua',
        dependencies = 'kyazdani42/nvim-web-devicons',
        config = function()
            require('user/plugins/nvim-tree')
        end,
    },

    -- A status line.
    {
        'nvim-lualine/lualine.nvim',
        dependencies = 'kyazdani42/nvim-web-devicons',
        config = function()
            require('user/plugins/lualine')
        end
    },

    {
      'echasnovski/mini.indentscope',
      version = '*',
      config = function()
        require('mini.indentscope').setup({})
      end
    },

    -- git plugin
    -- {
    --     'lewis6991/gitsigns.nvim',
    --     config = function()
    --         require('gitsigns').setup()
    --     end
    -- },

    {
        'voldikss/vim-floaterm',
        config = function()
            vim.g.floaterm_wintype = 'split' -- 'vsplit' is for vertical split
            vim.g.floaterm_height = 0.2
            -- vim.g.floaterm_width = 0.2
            vim.keymap.set('n', '<leader>`', ':FloatermToggle<CR>')
            vim.keymap.set('t', '<leader>`', '<C-\\><C-n>:FloatermToggle<CR>')
        end
    },

    {
      'nvim-treesitter/nvim-treesitter',
      lazy = false,

      branch = 'main',
      build = ':TSUpdate'
    },
    -- Improive syntax highlighting
    -- {
    --   "nvim-treesitter/nvim-treesitter",
    --   build = function()

    --     require("nvim-treesitter.install").update({ with_sync = true })()
    --   end,
    --   dependencies = {
    --     "JoosepAlviste/nvim-ts-context-commentstring",
    --     "nvim-treesitter/nvim-treesitter-textobjects",
    --   },
    --   config = function()
    --     require("user.plugins.treesitter")
    --   end,
    -- },


    -- Code folding
    {
        'kevinhwang91/nvim-ufo', 
        dependencies = 'kevinhwang91/promise-async',
        config = function()
            require('user/plugins/ufo')
        end
    },

    -- Language server protocol.
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            { 
                'williamboman/mason.nvim', 
                build = ':MasonUpdate' 
            },
            'williamboman/mason-lspconfig.nvim',
            'b0o/schemastore.nvim',
        },
        config = function()
            require('user/plugins/lspconfig')
        end
    },

    -- Formatter
    {
        "nvimtools/none-ls.nvim", -- Correct repository name
        dependencies = { 
            "nvim-lua/plenary.nvim" -- Ensure correct repository name for plenary.nvim
        },
        config = function()
            require('user.plugins.none-ls') -- Ensure the path matches your configuration file
        end
    },

    -- Autocompletion
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-nvim-lsp-signature-help',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip',
            'onsails/lspkind-nvim',
        },
        config = function()
            require('user/plugins/cmp')
        end,
    },

    -- Markdown preview
    {
        'MeanderingProgrammer/render-markdown.nvim',
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
        opts = {},
    },

    -- Avante - AI assistant just like Cursor but for Neovim
    {
      "yetone/avante.nvim",
      -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
      -- ⚠️ must add this setting! ! !
      build = vim.fn.has("win32")
          and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
          or "make",
      event = "VeryLazy",
      version = false, -- Never set this value to "*"! Never!
      ---@module 'avante'
      ---@type avante.Config
      opts = {
        provider = "ollama",
        providers = {
          ollama = {
            endpoint = "http://localhost:11434",
            model = "deepseek-coder:6.7b",
          },
        }
      },
      dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        --- The below dependencies are optional,
        "echasnovski/mini.pick", -- for file_selector provider mini.pick
        "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
        "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
        "ibhagwan/fzf-lua", -- for file_selector provider fzf
        "stevearc/dressing.nvim", -- for input provider dressing
        "folke/snacks.nvim", -- for input provider snacks
        "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
        "zbirenbaum/copilot.lua", -- for providers='copilot'
        {
          -- support for image pasting
          "HakonHarnes/img-clip.nvim",
          event = "VeryLazy",
          opts = {
            -- recommended settings
            default = {
              embed_image_as_base64 = false,
              prompt_for_file_name = false,
              drag_and_drop = {
                insert_mode = true,
              },
              -- required for Windows users
              use_absolute_path = true,
            },
          },
        },
        {
          -- Make sure to set this up properly if you have lazy=true
          'MeanderingProgrammer/render-markdown.nvim',
          opts = {
            file_types = { "markdown", "Avante" },
          },
          ft = { "markdown", "Avante" },
        },
      },
    }
})

