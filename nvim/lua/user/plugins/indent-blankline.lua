require('indent_blankline').setup({
    filetype_exclude = {
        'help',
        'terminal',
        'dashboard',
        'packer',
        'lspinfo',
        'TelescopePrompt',
        'TelescoprResults'
    },
    buftype_exclude = {
        'terminal',
        'NvimTree'
    }
})
