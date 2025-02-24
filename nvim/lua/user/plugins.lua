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
    'github/copilot.vim',

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
    {
        'lewis6991/gitsigns.nvim',
        config = function()
            require('gitsigns').setup()
        end
    },

    {
        'voldikss/vim-floaterm',
        config = function()
            vim.g.floaterm_wintype = 'vsplit'
            --vim.g.floaterm_height = 0.2
            vim.g.floaterm_width = 0.2
            vim.keymap.set('n', '<leader>`', ':FloatermToggle<CR>')
            vim.keymap.set('t', '<leader>`', '<C-\\><C-n>:FloatermToggle<CR>')
        end
    },

    -- Improive syntax highlighting
    -- use({
    --     'nvim-treesitter/nvim-treesitter',
    --     build = function()
    --         require('nvim-treesitter.install').update({ with_sync = true })
    --     end,
    --     dependencies = {
    --         'JoosepAlviste/nvim-ts-context-commentstring',
    --         'nvim-treesitter/nvim-treesitter-textobjects'
    --     },
    --     config = function()
    --         require('user.plugins.treesitter')
    --     end
    -- })

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
})

