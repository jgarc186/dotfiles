" matugen colourscheme — generated from /home/jose/developer/dotfiles/wallpapers/wolverine-heroic-legacy-w2-1366x768.jpg in dark mode.
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
hi Normal        guibg=#111418 guifg=#e1e2e8
hi NormalNC      guibg=#111418 guifg=#e1e2e8
hi NormalFloat   guibg=#1d2024 guifg=#e1e2e8
hi FloatBorder   guibg=#1d2024 guifg=#43474e
hi FloatTitle    guibg=#1d2024 guifg=#a2c9fd gui=bold

hi Cursor        guibg=#a2c9fd guifg=#00325a
hi lCursor       guibg=#a2c9fd guifg=#00325a
hi TermCursor    guibg=#a2c9fd guifg=#00325a
hi CursorLine    guibg=#272a2f
hi CursorColumn  guibg=#272a2f
hi ColorColumn   guibg=#1d2024
hi CursorLineNr  guibg=None guifg=#a2c9fd gui=bold
hi LineNr        guibg=None guifg=#8d9199
hi SignColumn    guibg=None guifg=#8d9199
hi FoldColumn    guibg=None guifg=#8d9199
hi Folded        guibg=#1d2024 guifg=#c3c6cf

hi Visual        guibg=#3c4858 guifg=#d7e3f8
hi VisualNOS     guibg=#3c4858 guifg=#d7e3f8
hi Search        guibg=#533f5f guifg=#f4daff
hi IncSearch     guibg=#d7bde4 guifg=#3b2947
hi CurSearch     guibg=#d7bde4 guifg=#3b2947
hi MatchParen    guibg=#32353a guifg=#d7bde4 gui=bold
hi Substitute    guibg=#93000a guifg=#ffdad6

hi Pmenu         guibg=#1d2024 guifg=#e1e2e8
hi PmenuSel      guibg=#3c4858 guifg=#d7e3f8
hi PmenuSbar     guibg=#272a2f
hi PmenuThumb    guibg=#8d9199
hi WildMenu      guibg=#3c4858 guifg=#d7e3f8

hi StatusLine    guibg=#a2c9fd guifg=#00325a
hi StatusLineNC  guibg=#1c4975 guifg=#d2e4ff
hi TabLine       guibg=#1d2024 guifg=#c3c6cf
hi TabLineSel    guibg=#a2c9fd guifg=#00325a
hi TabLineFill   guibg=#191c20
hi WinBar        guibg=None guifg=#c3c6cf
hi WinBarNC      guibg=None guifg=#8d9199
hi WinSeparator  guibg=None guifg=#43474e
hi VertSplit     guibg=None guifg=#43474e

hi NonText       guibg=None guifg=#43474e
hi Whitespace    guibg=None guifg=#43474e
hi EndOfBuffer   guibg=None guifg=#43474e
hi Conceal       guibg=None guifg=#8d9199
hi Directory     guibg=None guifg=#a2c9fd
hi Title         guibg=None guifg=#d7bde4 gui=bold
hi QuickFixLine  guibg=#272a2f
hi SpecialKey    guibg=None guifg=#8d9199

hi ErrorMsg      guibg=None guifg=#ffb4ab
hi WarningMsg    guibg=None guifg=#d7bde4
hi MoreMsg       guibg=None guifg=#bbc7db
hi Question      guibg=None guifg=#bbc7db
hi ModeMsg       guibg=None guifg=#e1e2e8 gui=bold
hi MsgArea       guibg=None guifg=#e1e2e8

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
hi Comment       guibg=None guifg=#8d9199 gui=italic

hi Delimiter     guibg=None guifg=#385f84
hi Operator      guibg=None guifg=#385f84

hi Todo          guibg=None guifg=#3f6d98 gui=bold

hi Identifier    guibg=None guifg=#e1e2e8
hi Constant      guibg=None guifg=#d7bde4
hi Number        guibg=None guifg=#d7bde4
hi Float         guibg=None guifg=#d7bde4
hi Boolean       guibg=None guifg=#d7bde4
hi Type          guibg=None guifg=#f4daff
hi StorageClass  guibg=None guifg=#f4daff
hi Structure     guibg=None guifg=#f4daff
hi Typedef       guibg=None guifg=#f4daff
hi String        guibg=None guifg=#bbc7db
hi Character     guibg=None guifg=#bbc7db
hi Special       guibg=None guifg=#d7e3f8
hi SpecialChar   guibg=None guifg=#d7e3f8
hi PreProc       guibg=None guifg=#d7e3f8
hi Include       guibg=None guifg=#a2c9fd
hi Define        guibg=None guifg=#d2e4ff
hi Macro         guibg=None guifg=#ffb4ab
hi Function      guibg=None guifg=#a2c9fd
hi Statement     guibg=None guifg=#d2e4ff
hi Conditional   guibg=None guifg=#d2e4ff
hi Repeat        guibg=None guifg=#d2e4ff
hi Label         guibg=None guifg=#d2e4ff
hi Keyword       guibg=None guifg=#d2e4ff
hi Exception     guibg=None guifg=#d2e4ff
hi Tag           guibg=None guifg=#ffdad6
hi Debug         guibg=None guifg=#ffb4ab
hi Underlined    guibg=None guifg=#a2c9fd gui=underline
hi Ignore        guibg=None guifg=#8d9199

hi Error         guibg=#93000a guifg=#ffdad6
hi Selection     guibg=#243747

" -- Treesitter -------------------------------------------------------------
" Most @-groups default-link to the core groups above; these are the ones
" where the default link is too coarse to read well.
hi @variable          guibg=None guifg=#e1e2e8
hi @variable.builtin  guibg=None guifg=#ffb4ab gui=italic
hi @variable.member   guibg=None guifg=#c3c6cf
hi @property          guibg=None guifg=#c3c6cf
hi @constructor       guibg=None guifg=#f4daff
hi @module            guibg=None guifg=#f4daff
hi @string.escape     guibg=None guifg=#d7e3f8
hi @tag.attribute     guibg=None guifg=#f4daff gui=italic
hi @markup.link       guibg=None guifg=#a2c9fd gui=underline
hi @markup.raw        guibg=None guifg=#bbc7db
hi! link @markup.heading Title
hi! link @comment.note Todo

" -- Diagnostics ------------------------------------------------------------
hi DiagnosticError  guibg=None guifg=#ffb4ab
hi DiagnosticWarn   guibg=None guifg=#d7bde4
hi DiagnosticInfo   guibg=None guifg=#a2c9fd
hi DiagnosticHint   guibg=None guifg=#bbc7db
hi DiagnosticOk     guibg=None guifg=#bbc7db
hi DiagnosticUnderlineError  gui=undercurl guisp=#ffb4ab
hi DiagnosticUnderlineWarn   gui=undercurl guisp=#d7bde4
hi DiagnosticUnderlineInfo   gui=undercurl guisp=#a2c9fd
hi DiagnosticUnderlineHint   gui=undercurl guisp=#bbc7db

hi LspReferenceText   guibg=#272a2f
hi LspReferenceRead   guibg=#272a2f
hi LspReferenceWrite  guibg=#272a2f
hi LspInlayHint       guibg=None guifg=#8d9199 gui=italic

" -- Diffs ------------------------------------------------------------------
" Foreground-only: a tinted background would need a light/dark-specific blend,
" and this file has to render correctly in both modes from one source.
hi DiffAdd       guibg=None guifg=#bbc7db
hi DiffChange    guibg=None guifg=#a2c9fd
hi DiffDelete    guibg=None guifg=#ffb4ab
hi DiffText      guibg=None guifg=#f4daff gui=bold
hi! link Added   DiffAdd
hi! link Changed DiffChange
hi! link Removed DiffDelete

hi GitSignsAdd     guibg=None guifg=#bbc7db
hi GitSignsChange  guibg=None guifg=#a2c9fd
hi GitSignsDelete  guibg=None guifg=#ffb4ab

" -- Plugins ----------------------------------------------------------------
hi NvimTreeNormal          guibg=None guifg=#e1e2e8
hi NvimTreeRootFolder      guibg=None guifg=#d7bde4 gui=bold
hi NvimTreeFolderName      guibg=None guifg=#a2c9fd
hi NvimTreeOpenedFolderName guibg=None guifg=#a2c9fd gui=bold
hi NvimTreeFolderIcon      guibg=None guifg=#a2c9fd
hi NvimTreeSpecialFile     guibg=None guifg=#d7bde4
hi NvimTreeIndentMarker    guibg=None guifg=#43474e
hi NvimTreeWinSeparator    guibg=None guifg=#43474e

hi IblIndent  guibg=None guifg=#43474e
hi IblScope   guibg=None guifg=#8d9199

hi CmpItemAbbr        guibg=None guifg=#e1e2e8
hi CmpItemAbbrMatch   guibg=None guifg=#a2c9fd gui=bold
hi CmpItemAbbrDeprecated guibg=None guifg=#8d9199 gui=strikethrough
hi CmpItemKind        guibg=None guifg=#d7bde4
hi CmpItemMenu        guibg=None guifg=#8d9199

" -- :terminal --------------------------------------------------------------
" Same role mapping as the kitty template, so a shell inside nvim matches a
" shell outside it: base16 ramp for the greys (it inverts with the mode), M3
" roles for the hues (base08-base0F don't invert, so they wash out in light
" mode). Four hues for ANSI's six, hence magenta/cyan reusing blue/green
" tones swapped.
let g:terminal_color_0  = '#111418'
let g:terminal_color_8  = '#2b455b'
let g:terminal_color_1  = '#ffb4ab'
let g:terminal_color_9  = '#ffdad6'
let g:terminal_color_2  = '#bbc7db'
let g:terminal_color_10 = '#d7e3f8'
let g:terminal_color_3  = '#d7bde4'
let g:terminal_color_11 = '#f4daff'
let g:terminal_color_4  = '#a2c9fd'
let g:terminal_color_12 = '#d2e4ff'
let g:terminal_color_5  = '#d2e4ff'
let g:terminal_color_13 = '#a2c9fd'
let g:terminal_color_6  = '#d7e3f8'
let g:terminal_color_14 = '#bbc7db'
let g:terminal_color_7  = '#385f84'
let g:terminal_color_15 = '#e1e2e8'
