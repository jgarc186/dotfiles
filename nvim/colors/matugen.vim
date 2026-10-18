" matugen colourscheme — generated from /home/jose/developer/dotfiles/wallpapers/Wallpaper Violet Evergarden White And Black.png in dark mode.
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
hi Normal        guibg=#14140c guifg=#e5e3d6
hi NormalNC      guibg=#14140c guifg=#e5e3d6
hi NormalFloat   guibg=#202018 guifg=#e5e3d6
hi FloatBorder   guibg=#202018 guifg=#48473b
hi FloatTitle    guibg=#202018 guifg=#c8cc78 gui=bold

hi Cursor        guibg=#c8cc78 guifg=#313300
hi lCursor       guibg=#c8cc78 guifg=#313300
hi TermCursor    guibg=#c8cc78 guifg=#313300
hi CursorLine    guibg=#2b2a22
hi CursorColumn  guibg=#2b2a22
hi ColorColumn   guibg=#202018
hi CursorLineNr  guibg=None guifg=#c8cc78 gui=bold
hi LineNr        guibg=None guifg=#929182
hi SignColumn    guibg=None guifg=#929182
hi FoldColumn    guibg=None guifg=#929182
hi Folded        guibg=#202018 guifg=#c9c7b6

hi Visual        guibg=#47482d guifg=#e5e5c0
hi VisualNOS     guibg=#47482d guifg=#e5e5c0
hi Search        guibg=#244e41 guifg=#bfecda
hi IncSearch     guibg=#a3d0bf guifg=#09372b
hi CurSearch     guibg=#a3d0bf guifg=#09372b
hi MatchParen    guibg=#35352c guifg=#a3d0bf gui=bold
hi Substitute    guibg=#93000a guifg=#ffdad6

hi Pmenu         guibg=#202018 guifg=#e5e3d6
hi PmenuSel      guibg=#47482d guifg=#e5e5c0
hi PmenuSbar     guibg=#2b2a22
hi PmenuThumb    guibg=#929182
hi WildMenu      guibg=#47482d guifg=#e5e5c0

hi StatusLine    guibg=#c8cc78 guifg=#313300
hi StatusLineNC  guibg=#474a01 guifg=#e5e891
hi TabLine       guibg=#202018 guifg=#c9c7b6
hi TabLineSel    guibg=#c8cc78 guifg=#313300
hi TabLineFill   guibg=#1c1c14
hi WinBar        guibg=None guifg=#c9c7b6
hi WinBarNC      guibg=None guifg=#929182
hi WinSeparator  guibg=None guifg=#48473b
hi VertSplit     guibg=None guifg=#48473b

hi NonText       guibg=None guifg=#48473b
hi Whitespace    guibg=None guifg=#48473b
hi EndOfBuffer   guibg=None guifg=#48473b
hi Conceal       guibg=None guifg=#929182
hi Directory     guibg=None guifg=#c8cc78
hi Title         guibg=None guifg=#a3d0bf gui=bold
hi QuickFixLine  guibg=#2b2a22
hi SpecialKey    guibg=None guifg=#929182

hi ErrorMsg      guibg=None guifg=#ffb4ab
hi WarningMsg    guibg=None guifg=#a3d0bf
hi MoreMsg       guibg=None guifg=#c9c9a5
hi Question      guibg=None guifg=#c9c9a5
hi ModeMsg       guibg=None guifg=#e5e3d6 gui=bold
hi MsgArea       guibg=None guifg=#e5e3d6

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
hi Comment       guibg=None guifg=#929182 gui=italic

hi Delimiter     guibg=None guifg=#c5c3bc
hi Operator      guibg=None guifg=#c5c3bc

hi Todo          guibg=None guifg=#dddad3 gui=bold

hi Identifier    guibg=None guifg=#e5e3d6
hi Constant      guibg=None guifg=#a3d0bf
hi Number        guibg=None guifg=#a3d0bf
hi Float         guibg=None guifg=#a3d0bf
hi Boolean       guibg=None guifg=#a3d0bf
hi Type          guibg=None guifg=#bfecda
hi StorageClass  guibg=None guifg=#bfecda
hi Structure     guibg=None guifg=#bfecda
hi Typedef       guibg=None guifg=#bfecda
hi String        guibg=None guifg=#c9c9a5
hi Character     guibg=None guifg=#c9c9a5
hi Special       guibg=None guifg=#e5e5c0
hi SpecialChar   guibg=None guifg=#e5e5c0
hi PreProc       guibg=None guifg=#e5e5c0
hi Include       guibg=None guifg=#c8cc78
hi Define        guibg=None guifg=#e5e891
hi Macro         guibg=None guifg=#ffb4ab
hi Function      guibg=None guifg=#c8cc78
hi Statement     guibg=None guifg=#e5e891
hi Conditional   guibg=None guifg=#e5e891
hi Repeat        guibg=None guifg=#e5e891
hi Label         guibg=None guifg=#e5e891
hi Keyword       guibg=None guifg=#e5e891
hi Exception     guibg=None guifg=#e5e891
hi Tag           guibg=None guifg=#ffdad6
hi Debug         guibg=None guifg=#ffb4ab
hi Underlined    guibg=None guifg=#c8cc78 gui=underline
hi Ignore        guibg=None guifg=#929182

hi Error         guibg=#93000a guifg=#ffdad6
hi Selection     guibg=#7f7c77

" -- Treesitter -------------------------------------------------------------
" Most @-groups default-link to the core groups above; these are the ones
" where the default link is too coarse to read well.
hi @variable          guibg=None guifg=#e5e3d6
hi @variable.builtin  guibg=None guifg=#ffb4ab gui=italic
hi @variable.member   guibg=None guifg=#c9c7b6
hi @property          guibg=None guifg=#c9c7b6
hi @constructor       guibg=None guifg=#bfecda
hi @module            guibg=None guifg=#bfecda
hi @string.escape     guibg=None guifg=#e5e5c0
hi @tag.attribute     guibg=None guifg=#bfecda gui=italic
hi @markup.link       guibg=None guifg=#c8cc78 gui=underline
hi @markup.raw        guibg=None guifg=#c9c9a5
hi! link @markup.heading Title
hi! link @comment.note Todo

" -- Diagnostics ------------------------------------------------------------
hi DiagnosticError  guibg=None guifg=#ffb4ab
hi DiagnosticWarn   guibg=None guifg=#a3d0bf
hi DiagnosticInfo   guibg=None guifg=#c8cc78
hi DiagnosticHint   guibg=None guifg=#c9c9a5
hi DiagnosticOk     guibg=None guifg=#c9c9a5
hi DiagnosticUnderlineError  gui=undercurl guisp=#ffb4ab
hi DiagnosticUnderlineWarn   gui=undercurl guisp=#a3d0bf
hi DiagnosticUnderlineInfo   gui=undercurl guisp=#c8cc78
hi DiagnosticUnderlineHint   gui=undercurl guisp=#c9c9a5

hi LspReferenceText   guibg=#2b2a22
hi LspReferenceRead   guibg=#2b2a22
hi LspReferenceWrite  guibg=#2b2a22
hi LspInlayHint       guibg=None guifg=#929182 gui=italic

" -- Diffs ------------------------------------------------------------------
" Foreground-only: a tinted background would need a light/dark-specific blend,
" and this file has to render correctly in both modes from one source.
hi DiffAdd       guibg=None guifg=#c9c9a5
hi DiffChange    guibg=None guifg=#c8cc78
hi DiffDelete    guibg=None guifg=#ffb4ab
hi DiffText      guibg=None guifg=#bfecda gui=bold
hi! link Added   DiffAdd
hi! link Changed DiffChange
hi! link Removed DiffDelete

hi GitSignsAdd     guibg=None guifg=#c9c9a5
hi GitSignsChange  guibg=None guifg=#c8cc78
hi GitSignsDelete  guibg=None guifg=#ffb4ab

" -- Plugins ----------------------------------------------------------------
hi NvimTreeNormal          guibg=None guifg=#e5e3d6
hi NvimTreeRootFolder      guibg=None guifg=#a3d0bf gui=bold
hi NvimTreeFolderName      guibg=None guifg=#c8cc78
hi NvimTreeOpenedFolderName guibg=None guifg=#c8cc78 gui=bold
hi NvimTreeFolderIcon      guibg=None guifg=#c8cc78
hi NvimTreeSpecialFile     guibg=None guifg=#a3d0bf
hi NvimTreeIndentMarker    guibg=None guifg=#48473b
hi NvimTreeWinSeparator    guibg=None guifg=#48473b

hi IblIndent  guibg=None guifg=#48473b
hi IblScope   guibg=None guifg=#929182

hi CmpItemAbbr        guibg=None guifg=#e5e3d6
hi CmpItemAbbrMatch   guibg=None guifg=#c8cc78 gui=bold
hi CmpItemAbbrDeprecated guibg=None guifg=#929182 gui=strikethrough
hi CmpItemKind        guibg=None guifg=#a3d0bf
hi CmpItemMenu        guibg=None guifg=#929182

" -- :terminal --------------------------------------------------------------
" Same role mapping as the kitty template, so a shell inside nvim matches a
" shell outside it: base16 ramp for the greys (it inverts with the mode), M3
" roles for the hues (base08-base0F don't invert, so they wash out in light
" mode). Four hues for ANSI's six, hence magenta/cyan reusing blue/green
" tones swapped.
let g:terminal_color_0  = '#14140c'
let g:terminal_color_8  = '#96948e'
let g:terminal_color_1  = '#ffb4ab'
let g:terminal_color_9  = '#ffdad6'
let g:terminal_color_2  = '#c9c9a5'
let g:terminal_color_10 = '#e5e5c0'
let g:terminal_color_3  = '#a3d0bf'
let g:terminal_color_11 = '#bfecda'
let g:terminal_color_4  = '#c8cc78'
let g:terminal_color_12 = '#e5e891'
let g:terminal_color_5  = '#e5e891'
let g:terminal_color_13 = '#c8cc78'
let g:terminal_color_6  = '#e5e5c0'
let g:terminal_color_14 = '#c9c9a5'
let g:terminal_color_7  = '#c5c3bc'
let g:terminal_color_15 = '#e5e3d6'
