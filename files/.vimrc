set nocompatible
filetype indent plugin on
syntax on
set hidden
set confirm
set wildmenu
set showcmd
set hlsearch
set ignorecase
set smartcase
set backspace=indent,eol,start
set autoindent
set nostartofline
set ruler
set laststatus=2
set confirm
set visualbell
set t_vb=
set mouse=a
set cmdheight=2
set number
set notimeout ttimeout ttimeoutlen=200
set shiftwidth=4
set softtabstop=4
set expandtab
set showmatch		" Show matching brackets.
set ignorecase		" Do case insensitive matching
set smartcase		" Do smart case matching
set incsearch		" Incremental search
set autowrite		" Automatically save before commands like :next and :make
set ruler
set confirm
"Shifting_blocks_visually
vnoremap > >gv
vnoremap < <gv
"completions
   inoremap ( ()<Esc>i
   inoremap [ []<Esc>i
"   inoremap " ""<Esc>i
   inoremap ' ''<Esc>i
   inoremap { {}<Esc>i

"togle paste
set pastetoggle=<F2>
"continue from last postion
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

"vim latex
let g:livepreview_previewer = 'vprerex'
let g:livepreview_engine = 'xelatex'


"vim-airline confs

let g:airline#extensions#tabline#enabled = 1
call plug#begin()
Plug 'lervag/vimtex'
Plug 'xuhdev/vim-latex-live-preview', { 'for': 'tex' }
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'scrooloose/syntastic'
Plug 'airblade/vim-gitgutter'
Plug 'prettier/vim-prettier', {
  \ 'do': 'npm install',
  \ 'branch': 'release/1.x',
  \ 'for': [
    \ 'javascript',
    \ 'typescript',
    \ 'css',
    \ 'less',
    \ 'scss',
    \ 'json',
    \ 'graphql',
    \ 'markdown',
    \ 'vue',
    \ 'lua',
    \ 'php',
    \ 'python',
    \ 'ruby',
    \ 'html',
    \ 'ejs',
    \ 'swift' ] }
call plug#end()
