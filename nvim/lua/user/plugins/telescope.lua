local actions = require('telescope.actions')

vim.cmd([[
    highlight link TelescopePromptTitle PMenuSel
    highlight link TelescopePreviewTitle PMenuSel
    highlight link TelescopePromptNormal NormalFloat
    highlight link TelescopePromptBorder FloatBorder
    highlight link TelescoperNormal CursorLine
    highlight link TelescopeBorder CursorLineBg
]])

require('telescope').setup({
    defaults = {
        path_display = {
            truncate = 1
        },
        prompt_prefix = '⚡ ',
        selection_caret = ' ',
        layout_config = {
            prompt_position = 'top'
        },
        sorting_strategy = 'ascending',
        mappings = {
            i = {
                ['<esc>'] = actions.close,
                ['<C-Down>'] = actions.cycle_history_next,
                ['<C-Up>'] = actions.cycle_history_prev
            }
        },
        file_ignore_patterns = { '.git/' }
    },
    pickers = {
        find_files = {
            hidden = true
        },
        buffers = {
            previewer = false,
            layout_config = {

            }
        },
        oldfiles = {
            prompt_title = 'History'
        },
        lsp_references = {
            previewer = false
        }
    }
})


require('telescope').load_extension('fzf')
require('telescope').load_extension('live_grep_args')


-- KEY MAPPINGS

-- Search all files in the system
vim.keymap.set('n', '<leader>p', [[<cmd>lua require('telescope.builtin').find_files()<CR>]])

-- global search for text
vim.keymap.set('n', '<leader>g', [[<cmd>lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>]])

-- Open all recent files && history
vim.keymap.set('n', '<leader>e', [[<cmd>lua require('telescope.builtin').oldfiles()<CR>]])
