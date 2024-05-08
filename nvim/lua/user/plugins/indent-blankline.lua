require('ibl').setup({
     exclude = {
        filetypes = {
            'help',
            'terminal',
            'dashboard',
            'packer',
            'lspinfo',
            'TelescopePrompt',
            'TelescoprResults'
        },
        buftypes = {
            'terminal',
            'NvimTree'
        }
    }
})
