call pathogen#runtime_append_all_bundles()
"call pathogen#helptags()
autocmd FileType php set omnifunc=phpcomplete#CompletePHP

colorscheme acidcupcake

set formatoptions=tcroqw

set number
set titlestring=%f
set title
set cindent
set autoindent
set smartindent
set tabstop=4
set shiftwidth=4
set expandtab
set nowrap

set wildmode=longest,list,full
set wildmenu

set pastetoggle=<F2>

set smartindent "better indentation, e.g. comments to go to first column

map <F4> :NERDTreeToggle <CR>

map <F5> :set nowrap! <CR>
map <F6> :set nonumber! <CR>

map <F9> :GitDiff <CR>
map <F10> :GitCommit <CR>

"folding
set foldmethod=indent "fold based on indent
set foldnestmax=10 "deepest fold is 10 levels
set nofoldenable "dont fold by default
set foldlevel=3 "this is just what i use
au BufRead,BufNewFile bash-fc-* set filetype=sh "useful for using vi mode in Bash 
set splitbelow "Ensure that vertical splits add the new window on the bottom
set splitright "Ensure that horizontal splits add the new frame on the right

"comment out lines with #
map <Leader># :s:^:#:<CR>:nohl<CR> 
"remove comments from lines beginning with #
map <Leader>-# :s:#:^:<CR>:nohl<CR> 
"remap Perl array to hash, ignore topic variable $_
map <Leader>h :s/\$_\@!\(\w\+\),*/\1 => \$\1,\r\t/g<CR> 
