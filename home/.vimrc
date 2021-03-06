"call pathogen#infect()
"call pathogen#helptags()

set number
set titlestring=%f
set title
set cindent
set autoindent
set smartindent
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set nowrap
set list
set termguicolors

" set tabstop of 2 for certain languages
autocmd FileType ruby set tabstop=2|set softtabstop=2|set shiftwidth=2
autocmd FileType javascript set tabstop=2|set softtabstop=2|set shiftwidth=2
autocmd FileType yaml set tabstop=2|set softtabstop=2|set shiftwidth=2
autocmd FileType yml set tabstop=2|set softtabstop=2|set shiftwidth=2
autocmd FileType go set tabstop=4|set noexpandtab|set listchars=tab:\|\ ,trail:-,extends:>,precedes:<,nbsp:+|highlight SpecialKey guifg=#333333 guibg=#111111

" Vimplug config
call plug#begin()
Plug 'tpope/vim-sensible'
Plug 'pearofducks/ansible-vim'
Plug 'othree/eregex.vim'
Plug 'godlygeek/tabular'
Plug 'airblade/vim-gitgutter'
Plug 'junegunn/rainbow_parentheses.vim'
Plug 'rust-lang/rust.vim'
call plug#end()

" Remove default functionality for spacebar in normal mode,
" then set spacebar as leader key for custom shortcuts.
nnoremap <Space> <nop>
map <Space> <Leader>

" manually strip trailing whitespace throughout file
map <Leader>w :%s/\s\+$//e<CR>

map <Leader>t :Tabularize /

" Disable warning about files changing on disk.
" This happens all the time when branching in git...
autocmd FileChangedShell * echon ""
" Above fix doesn't work, so manually option below is a workaround.
" Re-opens all tabs in current window; mnemonic is 'git edit'.
map <Leader>ge :windo e!<CR>
" Disable annoying temp file recovery
set nobackup
set noswapfile
set nocompatible

" theme
" colorscheme alduin
" colorscheme mustang
" colorscheme kalisi
colorscheme acidcupcake

set formatoptions=tcroqw
filetype indent on

set clipboard=unnamed

set wildmode=longest,list,full
set wildmenu

" disable Ex mode (default binding 'Q')
nnoremap Q <nop>

"folding
set foldmethod=indent "fold based on indent
set foldnestmax=10 "deepest fold is 10 levels
set nofoldenable "dont fold by default
set foldlevel=3 "this is just what i use
au BufRead,BufNewFile bash-fc-* set filetype=sh "useful for using vi mode in Bash 
set splitbelow "Ensure that vertical splits add the new window on the bottom
set splitright "Ensure that horizontal splits add the new frame on the right

" Activate RainbowParentheses for Lisps and Clojure.
augroup rainbow_lisp
  autocmd!
  autocmd FileType lisp,clojure,scheme RainbowParentheses
augroup END

"comment out lines with #
map <Leader># :s:^:#:<CR>:nohl<CR> 
"comment out lines with //
map <Leader>\ :s:^://:<CR>:nohl<CR>
"remove comments from lines beginning with #
map <Leader>-# :s:#:^:<CR>:nohl<CR> 
"remove comments from lines beginning with //
map <Leader>-\ :s://:^:<CR>:nohl<CR> 
" Show syntax highlighting groups for word under cursor
nmap <C-S-P> :call <SID>SynStack()<CR>
function! <SID>SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc

" Quickly edit/reload the vimrc file
nmap <silent> <leader>ev :e $MYVIMRC<CR>
nmap <silent> <leader>sv :so $MYVIMRC<CR>
