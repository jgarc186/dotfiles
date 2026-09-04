" matugen colourscheme — generated from /home/jose/developer/dotfiles/wallpapers/eBYgF9K.png in dark mode.
"
" DO NOT EDIT the output (nvim/colors/matugen.vim): it is overwritten by every
" `matugen image` / `theme-mode` run. Edit this template instead.
"
" Colours are the Material 3 roles matugen emits (colors.*), so the editor
" tracks the wallpaper the same way waybar, rofi and kitty do. The base16
" greyscale ramp (base00-base07) is used where a tone rather than a hue is
" wanted; base08-base0F are deliberately NOT used — see the syntax section.
"
" Every value is `.default`, which is whatever --mode the run used. A
" hardcoded `.dark` renders dark colours into a light-mode run — that is the
" bug this template shipped with, and nvim/tests/test_theme.lua guards it.

hi clear
if exists('syntax_on')
  syntax reset
endif

set background=dark
let g:colors_name = 'matugen'

" -- Editor chrome ----------------------------------------------------------
" lua/user/theme.lua clears Normal's background afterwards to keep the
" terminal (also matugen-themed) showing through; it is set here so the
" colourscheme is still correct when loaded on its own.
hi Normal        guibg=#101418 guifg=#e0e2e8
hi NormalNC      guibg=#101418 guifg=#e0e2e8
hi NormalFloat   guibg=#1c2024 guifg=#e0e2e8
hi FloatBorder   guibg=#1c2024 guifg=#42474e
hi FloatTitle    guibg=#1c2024 guifg=#9ccbfb gui=bold

hi Cursor        guibg=#9ccbfb guifg=#003354
hi lCursor       guibg=#9ccbfb guifg=#003354
hi TermCursor    guibg=#9ccbfb guifg=#003354
hi CursorLine    guibg=#272a2f
hi CursorColumn  guibg=#272a2f
hi ColorColumn   guibg=#1c2024
hi CursorLineNr  guibg=None guifg=#9ccbfb gui=bold
hi LineNr        guibg=None guifg=#8c9199
hi SignColumn    guibg=None guifg=#8c9199
hi FoldColumn    guibg=None guifg=#8c9199
hi Folded        guibg=#1c2024 guifg=#c2c7cf

hi Visual        guibg=#3a4857 guifg=#d5e4f7
hi VisualNOS     guibg=#3a4857 guifg=#d5e4f7
hi Search        guibg=#504060 guifg=#efdbff
hi IncSearch     guibg=#d4bee6 guifg=#392a49
hi CurSearch     guibg=#d4bee6 guifg=#392a49
hi MatchParen    guibg=#32353a guifg=#d4bee6 gui=bold
hi Substitute    guibg=#93000a guifg=#ffdad6

hi Pmenu         guibg=#1c2024 guifg=#e0e2e8
hi PmenuSel      guibg=#3a4857 guifg=#d5e4f7
hi PmenuSbar     guibg=#272a2f
hi PmenuThumb    guibg=#8c9199
hi WildMenu      guibg=#3a4857 guifg=#d5e4f7

hi StatusLine    guibg=#9ccbfb guifg=#003354
hi StatusLineNC  guibg=#114a73 guifg=#cfe5ff
hi TabLine       guibg=#1c2024 guifg=#c2c7cf
hi TabLineSel    guibg=#9ccbfb guifg=#003354
hi TabLineFill   guibg=#181c20
hi WinBar        guibg=None guifg=#c2c7cf
hi WinBarNC      guibg=None guifg=#8c9199
hi WinSeparator  guibg=None guifg=#42474e
hi VertSplit     guibg=None guifg=#42474e

hi NonText       guibg=None guifg=#42474e
hi Whitespace    guibg=None guifg=#42474e
hi EndOfBuffer   guibg=None guifg=#42474e
hi Conceal       guibg=None guifg=#8c9199
hi Directory     guibg=None guifg=#9ccbfb
hi Title         guibg=None guifg=#d4bee6 gui=bold
hi QuickFixLine  guibg=#272a2f
hi SpecialKey    guibg=None guifg=#8c9199

hi ErrorMsg      guibg=None guifg=#ffb4ab
hi WarningMsg    guibg=None guifg=#d4bee6
hi MoreMsg       guibg=None guifg=#b9c8da
hi Question      guibg=None guifg=#b9c8da
hi ModeMsg       guibg=None guifg=#e0e2e8 gui=bold
hi MsgArea       guibg=None guifg=#e0e2e8

" -- Syntax -----------------------------------------------------------------
" Accents come from the M3 roles, not from base16. matugen's base08-base0F are
" identical in light and dark mode (only base00-base07 invert), so they render
" as near-white against a light background and several of them collapse into
" each other against a dark one. `X` and `on_X_container` are the two legible
" tones of one hue and both flip with the mode, which is what keeps syntax
" readable in either. Four hues (primary/secondary/tertiary/error) for more
" than four syntax categories means some share a colour — that is a matugen
" palette being monochromatic by design.
"
" The greys below (base03/base05/base06) are the base16 ramp, which does
" invert, so they stay correct in both modes.
" Comments want to be dim without disappearing: base03 lands around 2:1
" against the surface in light mode, where `outline` (M3's own low-emphasis
" role) clears 4:1 and still reads as secondary.
hi Comment       guibg=None guifg=#8c9199 gui=italic

hi Delimiter     guibg=None guifg=#963b51
hi Operator      guibg=None guifg=#963b51

hi Todo          guibg=None guifg=#b3435c gui=bold

hi Identifier    guibg=None guifg=#e0e2e8
hi Constant      guibg=None guifg=#d4bee6
hi Number        guibg=None guifg=#d4bee6
hi Float         guibg=None guifg=#d4bee6
hi Boolean       guibg=None guifg=#d4bee6
hi Type          guibg=None guifg=#efdbff
hi StorageClass  guibg=None guifg=#efdbff
hi Structure     guibg=None guifg=#efdbff
hi Typedef       guibg=None guifg=#efdbff
hi String        guibg=None guifg=#b9c8da
hi Character     guibg=None guifg=#b9c8da
hi Special       guibg=None guifg=#d5e4f7
hi SpecialChar   guibg=None guifg=#d5e4f7
hi PreProc       guibg=None guifg=#d5e4f7
hi Include       guibg=None guifg=#9ccbfb
hi Define        guibg=None guifg=#cfe5ff
hi Macro         guibg=None guifg=#ffb4ab
hi Function      guibg=None guifg=#9ccbfb
hi Statement     guibg=None guifg=#cfe5ff
hi Conditional   guibg=None guifg=#cfe5ff
hi Repeat        guibg=None guifg=#cfe5ff
hi Label         guibg=None guifg=#cfe5ff
hi Keyword       guibg=None guifg=#cfe5ff
hi Exception     guibg=None guifg=#cfe5ff
hi Tag           guibg=None guifg=#ffdad6
hi Debug         guibg=None guifg=#ffb4ab
hi Underlined    guibg=None guifg=#9ccbfb gui=underline
hi Ignore        guibg=None guifg=#8c9199

hi Error         guibg=#93000a guifg=#ffdad6
hi Selection     guibg=#412331

" -- Treesitter -------------------------------------------------------------
" Most @-groups default-link to the core groups above; these are the ones
" where the default link is too coarse to read well.
hi @variable          guibg=None guifg=#e0e2e8
hi @variable.builtin  guibg=None guifg=#ffb4ab gui=italic
hi @variable.member   guibg=None guifg=#c2c7cf
hi @property          guibg=None guifg=#c2c7cf
hi @constructor       guibg=None guifg=#efdbff
hi @module            guibg=None guifg=#efdbff
hi @string.escape     guibg=None guifg=#d5e4f7
hi @tag.attribute     guibg=None guifg=#efdbff gui=italic
hi @markup.link       guibg=None guifg=#9ccbfb gui=underline
hi @markup.raw        guibg=None guifg=#b9c8da
hi! link @markup.heading Title
hi! link @comment.note Todo

" -- Diagnostics ------------------------------------------------------------
hi DiagnosticError  guibg=None guifg=#ffb4ab
hi DiagnosticWarn   guibg=None guifg=#d4bee6
hi DiagnosticInfo   guibg=None guifg=#9ccbfb
hi DiagnosticHint   guibg=None guifg=#b9c8da
hi DiagnosticOk     guibg=None guifg=#b9c8da
hi DiagnosticUnderlineError  gui=undercurl guisp=#ffb4ab
hi DiagnosticUnderlineWarn   gui=undercurl guisp=#d4bee6
hi DiagnosticUnderlineInfo   gui=undercurl guisp=#9ccbfb
hi DiagnosticUnderlineHint   gui=undercurl guisp=#b9c8da

hi LspReferenceText   guibg=#272a2f
hi LspReferenceRead   guibg=#272a2f
hi LspReferenceWrite  guibg=#272a2f
hi LspInlayHint       guibg=None guifg=#8c9199 gui=italic

" -- Diffs ------------------------------------------------------------------
" Foreground-only: a tinted background would need a light/dark-specific blend,
" and this file has to render correctly in both modes from one source.
hi DiffAdd       guibg=None guifg=#b9c8da
hi DiffChange    guibg=None guifg=#9ccbfb
hi DiffDelete    guibg=None guifg=#ffb4ab
hi DiffText      guibg=None guifg=#efdbff gui=bold
hi! link Added   DiffAdd
hi! link Changed DiffChange
hi! link Removed DiffDelete

hi GitSignsAdd     guibg=None guifg=#b9c8da
hi GitSignsChange  guibg=None guifg=#9ccbfb
hi GitSignsDelete  guibg=None guifg=#ffb4ab

" -- Plugins ----------------------------------------------------------------
hi NvimTreeNormal          guibg=None guifg=#e0e2e8
hi NvimTreeRootFolder      guibg=None guifg=#d4bee6 gui=bold
hi NvimTreeFolderName      guibg=None guifg=#9ccbfb
hi NvimTreeOpenedFolderName guibg=None guifg=#9ccbfb gui=bold
hi NvimTreeFolderIcon      guibg=None guifg=#9ccbfb
hi NvimTreeSpecialFile     guibg=None guifg=#d4bee6
hi NvimTreeIndentMarker    guibg=None guifg=#42474e
hi NvimTreeWinSeparator    guibg=None guifg=#42474e

hi IblIndent  guibg=None guifg=#42474e
hi IblScope   guibg=None guifg=#8c9199

hi CmpItemAbbr        guibg=None guifg=#e0e2e8
hi CmpItemAbbrMatch   guibg=None guifg=#9ccbfb gui=bold
hi CmpItemAbbrDeprecated guibg=None guifg=#8c9199 gui=strikethrough
hi CmpItemKind        guibg=None guifg=#d4bee6
hi CmpItemMenu        guibg=None guifg=#8c9199

" -- :terminal --------------------------------------------------------------
" Same role mapping as the kitty template, so a shell inside nvim matches a
" shell outside it: base16 ramp for the greys (it inverts with the mode), M3
" roles for the hues (base08-base0F don't invert, so they wash out in light
" mode). Four hues for ANSI's six, hence magenta/cyan reusing blue/green
" tones swapped.
let g:terminal_color_0  = '#101418'
let g:terminal_color_8  = '#5d2b3c'
let g:terminal_color_1  = '#ffb4ab'
let g:terminal_color_9  = '#ffdad6'
let g:terminal_color_2  = '#b9c8da'
let g:terminal_color_10 = '#d5e4f7'
let g:terminal_color_3  = '#d4bee6'
let g:terminal_color_11 = '#efdbff'
let g:terminal_color_4  = '#9ccbfb'
let g:terminal_color_12 = '#cfe5ff'
let g:terminal_color_5  = '#cfe5ff'
let g:terminal_color_13 = '#9ccbfb'
let g:terminal_color_6  = '#d5e4f7'
let g:terminal_color_14 = '#b9c8da'
let g:terminal_color_7  = '#963b51'
let g:terminal_color_15 = '#e0e2e8'
