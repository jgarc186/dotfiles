require('nvim-tree').setup({
    git = {
        ignore = false,
    },
    renderer = {
        group_empty = true,
        icons = {
            show = {
                folder_arrow = false
            }
        },
        indent_markers = {
            enable = true
        }
    },
 })

local tree_api = require("nvim-tree")
local tree_view = require("nvim-tree.view")

vim.api.nvim_create_augroup("NvimTreeResize", {
  clear = true,
})

vim.api.nvim_create_autocmd({ "VimResized" }, {
  group = "NvimTreeResize",
  callback = function()
    if tree_view.is_visible() then
      tree_view.close()
      tree_api.open()
    end
  end
})

vim.keymap.set('n', '<leader>1', ':NvimTreeFindFileToggle<CR>')
