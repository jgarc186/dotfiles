" matugen colourscheme — generated from {{image}} in {{mode}} mode.
"
" DO NOT EDIT the output (nvim/colors/matugen.vim): it is overwritten by every
" `matugen image` / `theme-mode` run. Edit this template instead.
"
" Colours are the Material 3 roles matugen emits (colors.*) for UI chrome and
" its base16 mapping (base16.base0*) for syntax, so the editor tracks the
" wallpaper the same way waybar, rofi and kitty do.
"
" Every value is `.default`, which is whatever --mode the run used. A
" hardcoded `.dark` renders dark colours into a light-mode run — that is the
" bug this template shipped with, and nvim/tests/test_theme.lua guards it.

hi clear
if exists('syntax_on')
  syntax reset
endif

set background={{mode}}
let g:colors_name = 'matugen'

" -- Editor chrome ----------------------------------------------------------
" lua/user/theme.lua clears Normal's background afterwards to keep the
" terminal (also matugen-themed) showing through; it is set here so the
" colourscheme is still correct when loaded on its own.
hi Normal        guibg={{ colors.surface.default.hex }} guifg={{ colors.on_surface.default.hex }}
hi NormalNC      guibg={{ colors.surface.default.hex }} guifg={{ colors.on_surface.default.hex }}
hi NormalFloat   guibg={{ colors.surface_container.default.hex }} guifg={{ colors.on_surface.default.hex }}
hi FloatBorder   guibg={{ colors.surface_container.default.hex }} guifg={{ colors.outline_variant.default.hex }}
hi FloatTitle    guibg={{ colors.surface_container.default.hex }} guifg={{ colors.primary.default.hex }} gui=bold

hi Cursor        guibg={{ colors.primary.default.hex }} guifg={{ colors.on_primary.default.hex }}
hi lCursor       guibg={{ colors.primary.default.hex }} guifg={{ colors.on_primary.default.hex }}
hi TermCursor    guibg={{ colors.primary.default.hex }} guifg={{ colors.on_primary.default.hex }}
hi CursorLine    guibg={{ colors.surface_container_high.default.hex }}
hi CursorColumn  guibg={{ colors.surface_container_high.default.hex }}
hi ColorColumn   guibg={{ colors.surface_container.default.hex }}
hi CursorLineNr  guibg=None guifg={{ colors.primary.default.hex }} gui=bold
hi LineNr        guibg=None guifg={{ colors.outline.default.hex }}
hi SignColumn    guibg=None guifg={{ colors.outline.default.hex }}
hi FoldColumn    guibg=None guifg={{ colors.outline.default.hex }}
hi Folded        guibg={{ colors.surface_container.default.hex }} guifg={{ colors.on_surface_variant.default.hex }}

hi Visual        guibg={{ colors.secondary_container.default.hex }} guifg={{ colors.on_secondary_container.default.hex }}
hi VisualNOS     guibg={{ colors.secondary_container.default.hex }} guifg={{ colors.on_secondary_container.default.hex }}
hi Search        guibg={{ colors.tertiary_container.default.hex }} guifg={{ colors.on_tertiary_container.default.hex }}
hi IncSearch     guibg={{ colors.tertiary.default.hex }} guifg={{ colors.on_tertiary.default.hex }}
hi CurSearch     guibg={{ colors.tertiary.default.hex }} guifg={{ colors.on_tertiary.default.hex }}
hi MatchParen    guibg={{ colors.surface_container_highest.default.hex }} guifg={{ colors.tertiary.default.hex }} gui=bold
hi Substitute    guibg={{ colors.error_container.default.hex }} guifg={{ colors.on_error_container.default.hex }}

hi Pmenu         guibg={{ colors.surface_container.default.hex }} guifg={{ colors.on_surface.default.hex }}
hi PmenuSel      guibg={{ colors.secondary_container.default.hex }} guifg={{ colors.on_secondary_container.default.hex }}
hi PmenuSbar     guibg={{ colors.surface_container_high.default.hex }}
hi PmenuThumb    guibg={{ colors.outline.default.hex }}
hi WildMenu      guibg={{ colors.secondary_container.default.hex }} guifg={{ colors.on_secondary_container.default.hex }}

hi StatusLine    guibg={{ colors.primary.default.hex }} guifg={{ colors.on_primary.default.hex }}
hi StatusLineNC  guibg={{ colors.primary_container.default.hex }} guifg={{ colors.on_primary_container.default.hex }}
hi TabLine       guibg={{ colors.surface_container.default.hex }} guifg={{ colors.on_surface_variant.default.hex }}
hi TabLineSel    guibg={{ colors.primary.default.hex }} guifg={{ colors.on_primary.default.hex }}
hi TabLineFill   guibg={{ colors.surface_container_low.default.hex }}
hi WinBar        guibg=None guifg={{ colors.on_surface_variant.default.hex }}
hi WinBarNC      guibg=None guifg={{ colors.outline.default.hex }}
hi WinSeparator  guibg=None guifg={{ colors.outline_variant.default.hex }}
hi VertSplit     guibg=None guifg={{ colors.outline_variant.default.hex }}

hi NonText       guibg=None guifg={{ colors.outline_variant.default.hex }}
hi Whitespace    guibg=None guifg={{ colors.outline_variant.default.hex }}
hi EndOfBuffer   guibg=None guifg={{ colors.outline_variant.default.hex }}
hi Conceal       guibg=None guifg={{ colors.outline.default.hex }}
hi Directory     guibg=None guifg={{ colors.primary.default.hex }}
hi Title         guibg=None guifg={{ colors.tertiary.default.hex }} gui=bold
hi QuickFixLine  guibg={{ colors.surface_container_high.default.hex }}
hi SpecialKey    guibg=None guifg={{ colors.outline.default.hex }}

hi ErrorMsg      guibg=None guifg={{ colors.error.default.hex }}
hi WarningMsg    guibg=None guifg={{ colors.tertiary.default.hex }}
hi MoreMsg       guibg=None guifg={{ colors.secondary.default.hex }}
hi Question      guibg=None guifg={{ colors.secondary.default.hex }}
hi ModeMsg       guibg=None guifg={{ colors.on_surface.default.hex }} gui=bold
hi MsgArea       guibg=None guifg={{ colors.on_surface.default.hex }}

" -- Syntax -----------------------------------------------------------------
hi Comment       guibg=None guifg={{ base16.base03.default.hex }} gui=italic

hi Delimiter     guibg=None guifg={{ base16.base05.default.hex }}
hi Operator      guibg=None guifg={{ base16.base05.default.hex }}

hi Todo          guibg=None guifg={{ base16.base06.default.hex }} gui=bold

hi Identifier    guibg=None guifg={{ base16.base08.default.hex }}
hi Constant      guibg=None guifg={{ base16.base09.default.hex }}
hi Number        guibg=None guifg={{ base16.base09.default.hex }}
hi Float         guibg=None guifg={{ base16.base09.default.hex }}
hi Boolean       guibg=None guifg={{ base16.base09.default.hex }}
hi Type          guibg=None guifg={{ base16.base0a.default.hex }}
hi StorageClass  guibg=None guifg={{ base16.base0a.default.hex }}
hi Structure     guibg=None guifg={{ base16.base0a.default.hex }}
hi Typedef       guibg=None guifg={{ base16.base0a.default.hex }}
hi String        guibg=None guifg={{ base16.base0b.default.hex }}
hi Character     guibg=None guifg={{ base16.base0b.default.hex }}
hi Special       guibg=None guifg={{ base16.base0c.default.hex }}
hi SpecialChar   guibg=None guifg={{ base16.base0c.default.hex }}
hi PreProc       guibg=None guifg={{ base16.base0c.default.hex }}
hi Include       guibg=None guifg={{ base16.base0d.default.hex }}
hi Define        guibg=None guifg={{ base16.base0e.default.hex }}
hi Macro         guibg=None guifg={{ base16.base08.default.hex }}
hi Function      guibg=None guifg={{ base16.base0d.default.hex }}
hi Statement     guibg=None guifg={{ base16.base0e.default.hex }}
hi Conditional   guibg=None guifg={{ base16.base0e.default.hex }}
hi Repeat        guibg=None guifg={{ base16.base0e.default.hex }}
hi Label         guibg=None guifg={{ base16.base0e.default.hex }}
hi Keyword       guibg=None guifg={{ base16.base0e.default.hex }}
hi Exception     guibg=None guifg={{ base16.base0e.default.hex }}
hi Tag           guibg=None guifg={{ base16.base08.default.hex }}
hi Debug         guibg=None guifg={{ base16.base08.default.hex }}
hi Underlined    guibg=None guifg={{ base16.base0d.default.hex }} gui=underline
hi Ignore        guibg=None guifg={{ colors.outline.default.hex }}

hi Error         guibg={{ colors.error_container.default.hex }} guifg={{ colors.on_error_container.default.hex }}
hi Selection     guibg={{ base16.base02.default.hex }}

" -- Treesitter -------------------------------------------------------------
" Most @-groups default-link to the core groups above; these are the ones
" where the default link is too coarse to read well.
hi @variable          guibg=None guifg={{ colors.on_surface.default.hex }}
hi @variable.builtin  guibg=None guifg={{ base16.base08.default.hex }} gui=italic
hi @variable.member   guibg=None guifg={{ base16.base05.default.hex }}
hi @property          guibg=None guifg={{ base16.base05.default.hex }}
hi @constructor       guibg=None guifg={{ base16.base0a.default.hex }}
hi @module            guibg=None guifg={{ base16.base0a.default.hex }}
hi @string.escape     guibg=None guifg={{ base16.base0c.default.hex }}
hi @tag.attribute     guibg=None guifg={{ base16.base0a.default.hex }} gui=italic
hi @markup.link       guibg=None guifg={{ base16.base0d.default.hex }} gui=underline
hi @markup.raw        guibg=None guifg={{ base16.base0b.default.hex }}
hi! link @markup.heading Title
hi! link @comment.note Todo

" -- Diagnostics ------------------------------------------------------------
hi DiagnosticError  guibg=None guifg={{ colors.error.default.hex }}
hi DiagnosticWarn   guibg=None guifg={{ colors.tertiary.default.hex }}
hi DiagnosticInfo   guibg=None guifg={{ colors.primary.default.hex }}
hi DiagnosticHint   guibg=None guifg={{ colors.secondary.default.hex }}
hi DiagnosticOk     guibg=None guifg={{ base16.base0b.default.hex }}
hi DiagnosticUnderlineError  gui=undercurl guisp={{ colors.error.default.hex }}
hi DiagnosticUnderlineWarn   gui=undercurl guisp={{ colors.tertiary.default.hex }}
hi DiagnosticUnderlineInfo   gui=undercurl guisp={{ colors.primary.default.hex }}
hi DiagnosticUnderlineHint   gui=undercurl guisp={{ colors.secondary.default.hex }}

hi LspReferenceText   guibg={{ colors.surface_container_high.default.hex }}
hi LspReferenceRead   guibg={{ colors.surface_container_high.default.hex }}
hi LspReferenceWrite  guibg={{ colors.surface_container_high.default.hex }}
hi LspInlayHint       guibg=None guifg={{ colors.outline.default.hex }} gui=italic

" -- Diffs ------------------------------------------------------------------
" Foreground-only: a tinted background would need a light/dark-specific blend,
" and this file has to render correctly in both modes from one source.
hi DiffAdd       guibg=None guifg={{ base16.base0b.default.hex }}
hi DiffChange    guibg=None guifg={{ base16.base0d.default.hex }}
hi DiffDelete    guibg=None guifg={{ base16.base08.default.hex }}
hi DiffText      guibg=None guifg={{ base16.base0a.default.hex }} gui=bold
hi! link Added   DiffAdd
hi! link Changed DiffChange
hi! link Removed DiffDelete

hi GitSignsAdd     guibg=None guifg={{ base16.base0b.default.hex }}
hi GitSignsChange  guibg=None guifg={{ base16.base0d.default.hex }}
hi GitSignsDelete  guibg=None guifg={{ base16.base08.default.hex }}

" -- Plugins ----------------------------------------------------------------
hi NvimTreeNormal          guibg=None guifg={{ colors.on_surface.default.hex }}
hi NvimTreeRootFolder      guibg=None guifg={{ colors.tertiary.default.hex }} gui=bold
hi NvimTreeFolderName      guibg=None guifg={{ colors.primary.default.hex }}
hi NvimTreeOpenedFolderName guibg=None guifg={{ colors.primary.default.hex }} gui=bold
hi NvimTreeFolderIcon      guibg=None guifg={{ colors.primary.default.hex }}
hi NvimTreeSpecialFile     guibg=None guifg={{ colors.tertiary.default.hex }}
hi NvimTreeIndentMarker    guibg=None guifg={{ colors.outline_variant.default.hex }}
hi NvimTreeWinSeparator    guibg=None guifg={{ colors.outline_variant.default.hex }}

hi IblIndent  guibg=None guifg={{ colors.outline_variant.default.hex }}
hi IblScope   guibg=None guifg={{ colors.outline.default.hex }}

hi CmpItemAbbr        guibg=None guifg={{ colors.on_surface.default.hex }}
hi CmpItemAbbrMatch   guibg=None guifg={{ colors.primary.default.hex }} gui=bold
hi CmpItemAbbrDeprecated guibg=None guifg={{ colors.outline.default.hex }} gui=strikethrough
hi CmpItemKind        guibg=None guifg={{ colors.tertiary.default.hex }}
hi CmpItemMenu        guibg=None guifg={{ colors.outline.default.hex }}

" -- :terminal --------------------------------------------------------------
" Same role mapping as the kitty template, so a shell inside nvim matches a
" shell outside it.
let g:terminal_color_0  = '{{ colors.surface.default.hex }}'
let g:terminal_color_8  = '{{ colors.surface_container_highest.default.hex }}'
let g:terminal_color_1  = '{{ base16.base08.default.hex | lighten: -20.0 }}'
let g:terminal_color_9  = '{{ base16.base08.default.hex | lighten: 10.0 }}'
let g:terminal_color_2  = '{{ colors.secondary_fixed_dim.default.hex }}'
let g:terminal_color_10 = '{{ colors.secondary_fixed.default.hex }}'
let g:terminal_color_3  = '{{ colors.tertiary_fixed_dim.default.hex }}'
let g:terminal_color_11 = '{{ colors.tertiary_fixed.default.hex }}'
let g:terminal_color_4  = '{{ colors.on_primary_fixed_variant.default.hex }}'
let g:terminal_color_12 = '{{ colors.primary.default.hex }}'
let g:terminal_color_5  = '{{ colors.on_secondary_fixed_variant.default.hex }}'
let g:terminal_color_13 = '{{ colors.secondary.default.hex }}'
let g:terminal_color_6  = '{{ colors.on_tertiary_fixed_variant.default.hex }}'
let g:terminal_color_14 = '{{ colors.tertiary.default.hex }}'
let g:terminal_color_7  = '{{ colors.on_surface_variant.default.hex }}'
let g:terminal_color_15 = '{{ colors.on_surface.default.hex }}'
