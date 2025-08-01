require("nvim-tree").setup({
  view = {
    width = 50,
    side = "left",
  },
  git = {
    ignore = false,
  },
  renderer = {
    group_empty = true,
    icons = {
      show = {
        folder_arrow = false,
      },
    },

    indent_markers = {
      enable = true,
    },
  },
})

-- Safely reload tree on resize (without accessing internal APIs)
vim.api.nvim_create_augroup("NvimTreeResize", { clear = true })

vim.api.nvim_create_autocmd("VimResized", {
  group = "NvimTreeResize",
  callback = function()
    vim.cmd("NvimTreeRefresh")  -- safer than using removed internals
  end,
})

vim.keymap.set("n", "<leader>1", ":NvimTreeFindFileToggle<CR>", { noremap = true, silent = true })

