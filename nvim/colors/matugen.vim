" matugen colourscheme — generated from /home/jose/developer/dotfiles/wallpapers/Wallpaper Violet Evergarden White And Black.png in light mode.
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

set background=light
let g:colors_name = 'matugen'

" -- Editor chrome ----------------------------------------------------------
" lua/user/theme.lua clears Normal's background afterwards to keep the
" terminal (also matugen-themed) showing through; it is set here so the
" colourscheme is still correct when loaded on its own.
hi Normal        guibg=#fdfaec guifg=#1c1c14
hi NormalNC      guibg=#fdfaec guifg=#1c1c14
hi NormalFloat   guibg=#f1eee1 guifg=#1c1c14
hi FloatBorder   guibg=#f1eee1 guifg=#c9c7b6
hi FloatTitle    guibg=#f1eee1 guifg=#5f621a gui=bold

hi Cursor        guibg=#5f621a guifg=#ffffff
hi lCursor       guibg=#5f621a guifg=#ffffff
hi TermCursor    guibg=#5f621a guifg=#ffffff
hi CursorLine    guibg=#ebe8db
hi CursorColumn  guibg=#ebe8db
hi ColorColumn   guibg=#f1eee1
hi CursorLineNr  guibg=None guifg=#5f621a gui=bold
hi LineNr        guibg=None guifg=#797869
hi SignColumn    guibg=None guifg=#797869
hi FoldColumn    guibg=None guifg=#797869
hi Folded        guibg=#f1eee1 guifg=#48473b

hi Visual        guibg=#e5e5c0 guifg=#1c1d06
hi VisualNOS     guibg=#e5e5c0 guifg=#1c1d06
hi Search        guibg=#bfecda guifg=#002118
hi IncSearch     guibg=#3c6658 guifg=#ffffff
hi CurSearch     guibg=#3c6658 guifg=#ffffff
hi MatchParen    guibg=#e5e3d6 guifg=#3c6658 gui=bold
hi Substitute    guibg=#ffdad6 guifg=#410002

hi Pmenu         guibg=#f1eee1 guifg=#1c1c14
hi PmenuSel      guibg=#e5e5c0 guifg=#1c1d06
hi PmenuSbar     guibg=#ebe8db
hi PmenuThumb    guibg=#797869
hi WildMenu      guibg=#e5e5c0 guifg=#1c1d06

hi StatusLine    guibg=#5f621a guifg=#ffffff
hi StatusLineNC  guibg=#e5e891 guifg=#1c1d00
hi TabLine       guibg=#f1eee1 guifg=#48473b
hi TabLineSel    guibg=#5f621a guifg=#ffffff
hi TabLineFill   guibg=#f7f4e6
hi WinBar        guibg=None guifg=#48473b
hi WinBarNC      guibg=None guifg=#797869
hi WinSeparator  guibg=None guifg=#c9c7b6
hi VertSplit     guibg=None guifg=#c9c7b6

hi NonText       guibg=None guifg=#c9c7b6
hi Whitespace    guibg=None guifg=#c9c7b6
hi EndOfBuffer   guibg=None guifg=#c9c7b6
hi Conceal       guibg=None guifg=#797869
hi Directory     guibg=None guifg=#5f621a
hi Title         guibg=None guifg=#3c6658 gui=bold
hi QuickFixLine  guibg=#ebe8db
hi SpecialKey    guibg=None guifg=#797869

hi ErrorMsg      guibg=None guifg=#ba1a1a
hi WarningMsg    guibg=None guifg=#3c6658
hi MoreMsg       guibg=None guifg=#5f6043
hi Question      guibg=None guifg=#5f6043
hi ModeMsg       guibg=None guifg=#1c1c14 gui=bold
hi MsgArea       guibg=None guifg=#1c1c14

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
hi Comment       guibg=None guifg=#797869 gui=italic

hi Delimiter     guibg=None guifg=#7f7c77
hi Operator      guibg=None guifg=#7f7c77

hi Todo          guibg=None guifg=#676561 gui=bold

hi Identifier    guibg=None guifg=#1c1c14
hi Constant      guibg=None guifg=#3c6658
hi Number        guibg=None guifg=#3c6658
hi Float         guibg=None guifg=#3c6658
hi Boolean       guibg=None guifg=#3c6658
hi Type          guibg=None guifg=#002118
hi StorageClass  guibg=None guifg=#002118
hi Structure     guibg=None guifg=#002118
hi Typedef       guibg=None guifg=#002118
hi String        guibg=None guifg=#5f6043
hi Character     guibg=None guifg=#5f6043
hi Special       guibg=None guifg=#1c1d06
hi SpecialChar   guibg=None guifg=#1c1d06
hi PreProc       guibg=None guifg=#1c1d06
hi Include       guibg=None guifg=#5f621a
hi Define        guibg=None guifg=#1c1d00
hi Macro         guibg=None guifg=#ba1a1a
hi Function      guibg=None guifg=#5f621a
hi Statement     guibg=None guifg=#1c1d00
hi Conditional   guibg=None guifg=#1c1d00
hi Repeat        guibg=None guifg=#1c1d00
hi Label         guibg=None guifg=#1c1d00
hi Keyword       guibg=None guifg=#1c1d00
hi Exception     guibg=None guifg=#1c1d00
hi Tag           guibg=None guifg=#410002
hi Debug         guibg=None guifg=#ba1a1a
hi Underlined    guibg=None guifg=#5f621a gui=underline
hi Ignore        guibg=None guifg=#797869

hi Error         guibg=#ffdad6 guifg=#410002
hi Selection     guibg=#c5c3bc

" -- Treesitter -------------------------------------------------------------
" Most @-groups default-link to the core groups above; these are the ones
" where the default link is too coarse to read well.
hi @variable          guibg=None guifg=#1c1c14
hi @variable.builtin  guibg=None guifg=#ba1a1a gui=italic
hi @variable.member   guibg=None guifg=#48473b
hi @property          guibg=None guifg=#48473b
hi @constructor       guibg=None guifg=#002118
hi @module            guibg=None guifg=#002118
hi @string.escape     guibg=None guifg=#1c1d06
hi @tag.attribute     guibg=None guifg=#002118 gui=italic
hi @markup.link       guibg=None guifg=#5f621a gui=underline
hi @markup.raw        guibg=None guifg=#5f6043
hi! link @markup.heading Title
hi! link @comment.note Todo

" -- Diagnostics ------------------------------------------------------------
hi DiagnosticError  guibg=None guifg=#ba1a1a
hi DiagnosticWarn   guibg=None guifg=#3c6658
hi DiagnosticInfo   guibg=None guifg=#5f621a
hi DiagnosticHint   guibg=None guifg=#5f6043
hi DiagnosticOk     guibg=None guifg=#5f6043
hi DiagnosticUnderlineError  gui=undercurl guisp=#ba1a1a
hi DiagnosticUnderlineWarn   gui=undercurl guisp=#3c6658
hi DiagnosticUnderlineInfo   gui=undercurl guisp=#5f621a
hi DiagnosticUnderlineHint   gui=undercurl guisp=#5f6043

hi LspReferenceText   guibg=#ebe8db
hi LspReferenceRead   guibg=#ebe8db
hi LspReferenceWrite  guibg=#ebe8db
hi LspInlayHint       guibg=None guifg=#797869 gui=italic

" -- Diffs ------------------------------------------------------------------
" Foreground-only: a tinted background would need a light/dark-specific blend,
" and this file has to render correctly in both modes from one source.
hi DiffAdd       guibg=None guifg=#5f6043
hi DiffChange    guibg=None guifg=#5f621a
hi DiffDelete    guibg=None guifg=#ba1a1a
hi DiffText      guibg=None guifg=#002118 gui=bold
hi! link Added   DiffAdd
hi! link Changed DiffChange
hi! link Removed DiffDelete

hi GitSignsAdd     guibg=None guifg=#5f6043
hi GitSignsChange  guibg=None guifg=#5f621a
hi GitSignsDelete  guibg=None guifg=#ba1a1a

" -- Plugins ----------------------------------------------------------------
hi NvimTreeNormal          guibg=None guifg=#1c1c14
hi NvimTreeRootFolder      guibg=None guifg=#3c6658 gui=bold
hi NvimTreeFolderName      guibg=None guifg=#5f621a
hi NvimTreeOpenedFolderName guibg=None guifg=#5f621a gui=bold
hi NvimTreeFolderIcon      guibg=None guifg=#5f621a
hi NvimTreeSpecialFile     guibg=None guifg=#3c6658
hi NvimTreeIndentMarker    guibg=None guifg=#c9c7b6
hi NvimTreeWinSeparator    guibg=None guifg=#c9c7b6

hi IblIndent  guibg=None guifg=#c9c7b6
hi IblScope   guibg=None guifg=#797869

hi CmpItemAbbr        guibg=None guifg=#1c1c14
hi CmpItemAbbrMatch   guibg=None guifg=#5f621a gui=bold
hi CmpItemAbbrDeprecated guibg=None guifg=#797869 gui=strikethrough
hi CmpItemKind        guibg=None guifg=#3c6658
hi CmpItemMenu        guibg=None guifg=#797869

" -- :terminal --------------------------------------------------------------
" Same role mapping as the kitty template, so a shell inside nvim matches a
" shell outside it: base16 ramp for the greys (it inverts with the mode), M3
" roles for the hues (base08-base0F don't invert, so they wash out in light
" mode). Four hues for ANSI's six, hence magenta/cyan reusing blue/green
" tones swapped.
let g:terminal_color_0  = '#fdfaec'
let g:terminal_color_8  = '#aeaba5'
let g:terminal_color_1  = '#ba1a1a'
let g:terminal_color_9  = '#410002'
let g:terminal_color_2  = '#5f6043'
let g:terminal_color_10 = '#1c1d06'
let g:terminal_color_3  = '#3c6658'
let g:terminal_color_11 = '#002118'
let g:terminal_color_4  = '#5f621a'
let g:terminal_color_12 = '#1c1d00'
let g:terminal_color_5  = '#1c1d00'
let g:terminal_color_13 = '#5f621a'
let g:terminal_color_6  = '#1c1d06'
let g:terminal_color_14 = '#5f6043'
let g:terminal_color_7  = '#7f7c77'
let g:terminal_color_15 = '#1c1c14'
