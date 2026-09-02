-- https://www.youtube.com/watch?v=WyLDEMjlz-o&t=532s
require('bufferline').setup({
   options = {
       indicator = {
           icon = ' '
       },
       show_close_icon = false,
       tab_size = 0,
       max_name_length = 25,
       offsets = {
           {
               filetype = 'NvimTree',
               text = '🗀  Files',
               highlight = 'StatusLine',
               text_align = 'left'
           }
       },
       separator_style = 'slant',
       modified_icon = '*',
       custom_areas = {
           -- The function runs on every redraw, so reading the colour from a
           -- highlight group here (rather than hardcoding a hex) keeps this
           -- spacer on the matugen palette across a light/dark switch.
           left = function()
               local fg = vim.api.nvim_get_hl(0, { name = 'Directory', link = false }).fg
               return {
                   { text = '    ', fg = fg and string.format('#%06x', fg) or nil }
               }
           end
       },
   }
})
