local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

require('packer').reset()
require('packer').init({
	compile_path = vim.fn.stdpath('data')..'/site/plugin/packer_compiled.lua',
    display = {
        open_fn = function()
            return require('packer.util').float({ border = 'solid' })
        end,
    }
})

local use = require('packer').use

-- My plugins here
-- Packer manage itself.
use('wbthomason/packer.nvim')

-- Themes
use({
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
})

-- Github Copilot
use('github/copilot.vim')

-- Commenting support
use('tpope/vim-commentary')

-- Fuzzy finder
use({
    'nvim-telescope/telescope.nvim',
    requires = {
        'nvim-lua/plenary.nvim',
        'kyazdani42/nvim-web-devicons',
        'nvim-telescope/telescope-live-grep-args.nvim',
        { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
    },
    config = function()
        require('user/plugins/telescope')
    end,
})

-- File tree sidebar
use({
    'kyazdani42/nvim-tree.lua',
    requires = 'kyazdani42/nvim-web-devicons',
    config = function()
        require('user/plugins/nvim-tree')
    end,
})

-- A status line.
use({
    'nvim-lualine/lualine.nvim',
    requires = 'kyazdani42/nvim-web-devicons',
    config = function()
        require('user/plugins/lualine')
    end
})

-- Display Buffers as tabs
use({
    'akinsho/bufferline.nvim',
    requires = 'kyazdani42/nvim-web-devicons',
    after = 'catppuccin',
    config = function()
        require('user/plugins/bufferline')
    end
})

-- Display indentation lines.
use({
    'lukas-reineke/indent-blankline.nvim',
    config = function()
        require('user/plugins/indent-blankline')
    end
})

-- git plugin
use({
    'lewis6991/gitsigns.nvim',
    config = function()
        require('gitsigns').setup()
    end
})

use({
    'voldikss/vim-floaterm',
    config = function()
        vim.g.floaterm_wintype = 'vsplit'
        --vim.g.floaterm_height = 0.2
        vim.g.floaterm_width = 0.2
        vim.keymap.set('n', '<leader>`', ':FloatermToggle<CR>')
        vim.keymap.set('t', '<leader>`', '<C-\\><C-n>:FloatermToggle<CR>')
    end
})

-- Improive syntax highlighting
use({
    'nvim-treesitter/nvim-treesitter',
    run = function()
        require('nvim-treesitter.install').update({ with_sync = true })
    end,
    requires = {
        'JoosepAlviste/nvim-ts-context-commentstring',
        'nvim-treesitter/nvim-treesitter-textobjects'
    },
    config = function()
        require('user.plugins.treesitter')
    end
})

-- Language server protocol.
use({
    'neovim/nvim-lspconfig',
    requires = {
        { 'williamboman/mason.nvim', build = ':MasonUpdate' },
        'williamboman/mason-lspconfig.nvim'
    },
    config = function()
        require('user/plugins/lspconfig')
    end
})

-- Automatically set up your configuration after cloning packer.nvim
-- Put this at the end after all plugins
if packer_bootstrap then
	require('packer').sync()
end

vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> 
  augroup end
]])
