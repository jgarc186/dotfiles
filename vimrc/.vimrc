syntax enable

colorscheme "atom-dark-256"

set backspace=indent,eol,start

" the default for the leader key is \, but , is better
let mapleader = ","
" set number

"---------Search-----------"
set hlsearch

"---------Mappings------------"
" Helps to give you instant access to edit the .vimrc file
nmap <leader>ev :e ~/.vimrc<cr>
nmap <leader><space> :nohlsearch<cr>

"------- Auto Commands -------"
"Helps to source the vimrc file on save.
autocmd BufWritePost .vimrc source %
