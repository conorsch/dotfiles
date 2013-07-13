call pathogen#runtime_append_all_bundles()
"call pathogen#helptags()
autocmd FileType php set omnifunc=phpcomplete#CompletePHP
autocmd Filetype html setlocal ts=2 sts=2 sw=2
autocmd Filetype ruby setlocal ts=2 sts=2 sw=2
autocmd Filetype javascript setlocal ts=2 sts=2 sw=2
autocmd Filetype python setlocal ts=4 sts=4 sw=4
autocmd Filetype perl setlocal ts=4 sts=4 sw=4
set expandtab

colorscheme acidcupcake

set formatoptions=tcroqw
filetype indent on

set nocompatible
set nobackup
set noswapfile

set number
set titlestring=%f
set title
set cindent
set autoindent
set smartindent
set nowrap

set wildmode=longest,list,full
set wildmenu

" reformat file using perltidy
noremap <Leader>t :%!perltidy -q<CR> 

set pastetoggle=<F2>

map <Leader>n :NERDTreeToggle<CR>

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
"comment out lines with //
map <Leader>\ :s:^://:<CR>:nohl<CR>
"remove comments from lines beginning with #
map <Leader>-# :s:#:^:<CR>:nohl<CR> 
"remove comments from lines beginning with //
map <Leader>-\ :s://:^:<CR>:nohl<CR> 
"remap Perl array to hash, ignore topic variable $_
map <Leader>h :s/\$_\@!\(\w\+\),*/\1 => \$\1,\r\t/g<CR> 
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

" tips for writing prose in vim, from http://alols.github.com/2012/11/07/writing-prose-with-vim/
command! Prose inoremap <buffer> . .<C-G>u|
            \ inoremap <buffer> ! !<C-G>u|
            \ inoremap <buffer> ? ?<C-G>u|
            \ setlocal spell spelllang=sv,en
            \     nolist nowrap tw=74 fo=t1 nonu|
            \ augroup PROSE|
            \   autocmd InsertEnter <buffer> set fo+=a|
            \   autocmd InsertLeave <buffer> set fo-=a|
            \ augroup END

command! Code silent! iunmap <buffer> .|
            \ silent! iunmap <buffer> !|
            \ silent! iunmap <buffer> ?|
            \ setlocal nospell list nowrap
            \     tw=74 fo=cqr1 showbreak=… nu|
            \ silent! autocmd! PROSE * <buffer>

command! -range=% SoftWrap
            \ <line2>put _ |
            \ <line1>,<line2>g/.\+/ .;-/^$/ join |normal $x
