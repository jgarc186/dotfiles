require('nvim-treesitter.configs').setup({
    ensure_installed = 'all',
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = true
    },
    context_commentsring = {
        enable = true
    },
    textobjects = {
        select = {
            enable = true,
            lookahead = true,
            keymap = {
                ['if'] = '@function.inner',
                ['af'] = '@function.outer',
                ['ia'] = '@paramter.inner',
                ['aa'] = '@paramter.outer'
            }
        }
    }
})
