require('user/plugins')
require('user/options')
require('user/keymaps')

-- Automatically source options.lua on BufEnter
vim.api.nvim_create_autocmd('BufEnter', {
    pattern = '*',
    command = 'source ~/developer/josegarcia/dotfiles/nvim/lua/user/options.lua'
})
