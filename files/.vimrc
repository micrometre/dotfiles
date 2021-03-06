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

"vim-airline confs
let g:airline#extensions#tabline#enabled = 1
"Latex configs
let g:gitgutter_terminal_reports_focus=0
let g:livepreview_previewer = 'vprerex'
"mark up preview
" the port on which Livedown server will run
let g:livedown_port = 1337
" the browser to use, can also be firefox, chrome or other, depending on your executable
let g:livedown_browser = "chrome"
call plug#begin()
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'scrooloose/syntastic'
Plug 'iamcco/mathjax-support-for-mkdp'
Plug 'iamcco/markdown-preview.vim'
Plug 'airblade/vim-gitgutter'
Plug 'lervag/vimtex'
Plug 'xuhdev/vim-latex-live-preview', { 'for': 'tex' }
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
