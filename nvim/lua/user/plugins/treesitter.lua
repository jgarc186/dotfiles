require('nvim-treesitter.configs').setup({
  ensure_installed = "all", -- or use a list like { "lua", "javascript", "python" }

  highlight = {
    enable = true,
    additional_vim_regex_highlighting = true,
  },

  context_commentstring = {
    enable = true,
    enable_autocmd = false, -- optional: avoids conflicts with Comment.nvim
  },

  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ["if"] = "@function.inner",
        ["af"] = "@function.outer",

        ["ia"] = "@parameter.inner",
        ["aa"] = "@parameter.outer",

      },
    },
  },
})
