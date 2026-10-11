" matugen colourscheme — generated from /home/jose/developer/dotfiles/wallpapers/spider-man-miles-morales-gradient-neon-desktop-wallpaper-4k.jpg in dark mode.
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
hi Normal        guibg=#191113 guifg=#efdee0
hi NormalNC      guibg=#191113 guifg=#efdee0
hi NormalFloat   guibg=#261d1f guifg=#efdee0
hi FloatBorder   guibg=#261d1f guifg=#524345
hi FloatTitle    guibg=#261d1f guifg=#ffb1c0 gui=bold

hi Cursor        guibg=#ffb1c0 guifg=#551d2c
hi lCursor       guibg=#ffb1c0 guifg=#551d2c
hi TermCursor    guibg=#ffb1c0 guifg=#551d2c
hi CursorLine    guibg=#312829
hi CursorColumn  guibg=#312829
hi ColorColumn   guibg=#261d1f
hi CursorLineNr  guibg=None guifg=#ffb1c0 gui=bold
hi LineNr        guibg=None guifg=#9f8c8f
hi SignColumn    guibg=None guifg=#9f8c8f
hi FoldColumn    guibg=None guifg=#9f8c8f
hi Folded        guibg=#261d1f guifg=#d6c2c4

hi Visual        guibg=#5c3f44 guifg=#ffd9df
hi VisualNOS     guibg=#5c3f44 guifg=#ffd9df
hi Search        guibg=#5f401d guifg=#ffdcbc
hi IncSearch     guibg=#ecbe90 guifg=#462a08
hi CurSearch     guibg=#ecbe90 guifg=#462a08
hi MatchParen    guibg=#3c3234 guifg=#ecbe90 gui=bold
hi Substitute    guibg=#93000a guifg=#ffdad6

hi Pmenu         guibg=#261d1f guifg=#efdee0
hi PmenuSel      guibg=#5c3f44 guifg=#ffd9df
hi PmenuSbar     guibg=#312829
hi PmenuThumb    guibg=#9f8c8f
hi WildMenu      guibg=#5c3f44 guifg=#ffd9df

hi StatusLine    guibg=#ffb1c0 guifg=#551d2c
hi StatusLineNC  guibg=#713342 guifg=#ffd9df
hi TabLine       guibg=#261d1f guifg=#d6c2c4
hi TabLineSel    guibg=#ffb1c0 guifg=#551d2c
hi TabLineFill   guibg=#22191b
hi WinBar        guibg=None guifg=#d6c2c4
hi WinBarNC      guibg=None guifg=#9f8c8f
hi WinSeparator  guibg=None guifg=#524345
hi VertSplit     guibg=None guifg=#524345

hi NonText       guibg=None guifg=#524345
hi Whitespace    guibg=None guifg=#524345
hi EndOfBuffer   guibg=None guifg=#524345
hi Conceal       guibg=None guifg=#9f8c8f
hi Directory     guibg=None guifg=#ffb1c0
hi Title         guibg=None guifg=#ecbe90 gui=bold
hi QuickFixLine  guibg=#312829
hi SpecialKey    guibg=None guifg=#9f8c8f

hi ErrorMsg      guibg=None guifg=#ffb4ab
hi WarningMsg    guibg=None guifg=#ecbe90
hi MoreMsg       guibg=None guifg=#e4bdc3
hi Question      guibg=None guifg=#e4bdc3
hi ModeMsg       guibg=None guifg=#efdee0 gui=bold
hi MsgArea       guibg=None guifg=#efdee0

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
hi Comment       guibg=None guifg=#9f8c8f gui=italic

hi Delimiter     guibg=None guifg=#ad86b0
hi Operator      guibg=None guifg=#ad86b0

hi Todo          guibg=None guifg=#cb9abf gui=bold

hi Identifier    guibg=None guifg=#efdee0
hi Constant      guibg=None guifg=#ecbe90
hi Number        guibg=None guifg=#ecbe90
hi Float         guibg=None guifg=#ecbe90
hi Boolean       guibg=None guifg=#ecbe90
hi Type          guibg=None guifg=#ffdcbc
hi StorageClass  guibg=None guifg=#ffdcbc
hi Structure     guibg=None guifg=#ffdcbc
hi Typedef       guibg=None guifg=#ffdcbc
hi String        guibg=None guifg=#e4bdc3
hi Character     guibg=None guifg=#e4bdc3
hi Special       guibg=None guifg=#ffd9df
hi SpecialChar   guibg=None guifg=#ffd9df
hi PreProc       guibg=None guifg=#ffd9df
hi Include       guibg=None guifg=#ffb1c0
hi Define        guibg=None guifg=#ffd9df
hi Macro         guibg=None guifg=#ffb4ab
hi Function      guibg=None guifg=#ffb1c0
hi Statement     guibg=None guifg=#ffd9df
hi Conditional   guibg=None guifg=#ffd9df
hi Repeat        guibg=None guifg=#ffd9df
hi Label         guibg=None guifg=#ffd9df
hi Keyword       guibg=None guifg=#ffd9df
hi Exception     guibg=None guifg=#ffd9df
hi Tag           guibg=None guifg=#ffdad6
hi Debug         guibg=None guifg=#ffb4ab
hi Underlined    guibg=None guifg=#ffb1c0 gui=underline
hi Ignore        guibg=None guifg=#9f8c8f

hi Error         guibg=#93000a guifg=#ffdad6
hi Selection     guibg=#534a83

" -- Treesitter -------------------------------------------------------------
" Most @-groups default-link to the core groups above; these are the ones
" where the default link is too coarse to read well.
hi @variable          guibg=None guifg=#efdee0
hi @variable.builtin  guibg=None guifg=#ffb4ab gui=italic
hi @variable.member   guibg=None guifg=#d6c2c4
hi @property          guibg=None guifg=#d6c2c4
hi @constructor       guibg=None guifg=#ffdcbc
hi @module            guibg=None guifg=#ffdcbc
hi @string.escape     guibg=None guifg=#ffd9df
hi @tag.attribute     guibg=None guifg=#ffdcbc gui=italic
hi @markup.link       guibg=None guifg=#ffb1c0 gui=underline
hi @markup.raw        guibg=None guifg=#e4bdc3
hi! link @markup.heading Title
hi! link @comment.note Todo

" -- Diagnostics ------------------------------------------------------------
hi DiagnosticError  guibg=None guifg=#ffb4ab
hi DiagnosticWarn   guibg=None guifg=#ecbe90
hi DiagnosticInfo   guibg=None guifg=#ffb1c0
hi DiagnosticHint   guibg=None guifg=#e4bdc3
hi DiagnosticOk     guibg=None guifg=#e4bdc3
hi DiagnosticUnderlineError  gui=undercurl guisp=#ffb4ab
hi DiagnosticUnderlineWarn   gui=undercurl guisp=#ecbe90
hi DiagnosticUnderlineInfo   gui=undercurl guisp=#ffb1c0
hi DiagnosticUnderlineHint   gui=undercurl guisp=#e4bdc3

hi LspReferenceText   guibg=#312829
hi LspReferenceRead   guibg=#312829
hi LspReferenceWrite  guibg=#312829
hi LspInlayHint       guibg=None guifg=#9f8c8f gui=italic

" -- Diffs ------------------------------------------------------------------
" Foreground-only: a tinted background would need a light/dark-specific blend,
" and this file has to render correctly in both modes from one source.
hi DiffAdd       guibg=None guifg=#e4bdc3
hi DiffChange    guibg=None guifg=#ffb1c0
hi DiffDelete    guibg=None guifg=#ffb4ab
hi DiffText      guibg=None guifg=#ffdcbc gui=bold
hi! link Added   DiffAdd
hi! link Changed DiffChange
hi! link Removed DiffDelete

hi GitSignsAdd     guibg=None guifg=#e4bdc3
hi GitSignsChange  guibg=None guifg=#ffb1c0
hi GitSignsDelete  guibg=None guifg=#ffb4ab

" -- Plugins ----------------------------------------------------------------
hi NvimTreeNormal          guibg=None guifg=#efdee0
hi NvimTreeRootFolder      guibg=None guifg=#ecbe90 gui=bold
hi NvimTreeFolderName      guibg=None guifg=#ffb1c0
hi NvimTreeOpenedFolderName guibg=None guifg=#ffb1c0 gui=bold
hi NvimTreeFolderIcon      guibg=None guifg=#ffb1c0
hi NvimTreeSpecialFile     guibg=None guifg=#ecbe90
hi NvimTreeIndentMarker    guibg=None guifg=#524345
hi NvimTreeWinSeparator    guibg=None guifg=#524345

hi IblIndent  guibg=None guifg=#524345
hi IblScope   guibg=None guifg=#9f8c8f

hi CmpItemAbbr        guibg=None guifg=#efdee0
hi CmpItemAbbrMatch   guibg=None guifg=#ffb1c0 gui=bold
hi CmpItemAbbrDeprecated guibg=None guifg=#9f8c8f gui=strikethrough
hi CmpItemKind        guibg=None guifg=#ecbe90
hi CmpItemMenu        guibg=None guifg=#9f8c8f

" -- :terminal --------------------------------------------------------------
" Same role mapping as the kitty template, so a shell inside nvim matches a
" shell outside it: base16 ramp for the greys (it inverts with the mode), M3
" roles for the hues (base08-base0F don't invert, so they wash out in light
" mode). Four hues for ANSI's six, hence magenta/cyan reusing blue/green
" tones swapped.
let g:terminal_color_0  = '#191113'
let g:terminal_color_8  = '#715e92'
let g:terminal_color_1  = '#ffb4ab'
let g:terminal_color_9  = '#ffdad6'
let g:terminal_color_2  = '#e4bdc3'
let g:terminal_color_10 = '#ffd9df'
let g:terminal_color_3  = '#ecbe90'
let g:terminal_color_11 = '#ffdcbc'
let g:terminal_color_4  = '#ffb1c0'
let g:terminal_color_12 = '#ffd9df'
let g:terminal_color_5  = '#ffd9df'
let g:terminal_color_13 = '#ffb1c0'
let g:terminal_color_6  = '#ffd9df'
let g:terminal_color_14 = '#e4bdc3'
let g:terminal_color_7  = '#ad86b0'
let g:terminal_color_15 = '#efdee0'
