" Vim color file
" Name:       sumi.vim
" Maintainer: Shawn M Moore <code@sartak.org>
" Homepage:   http://github.com/sartak/sumi/
"
" Designed for 256-color xterm.
"
" Forked from inkpot https://github.com/ciaranm/inkpot

set background=dark
hi clear
if exists("syntax_on")
   syntax reset
endif

let colors_name = "sumi"

hi Normal         cterm=NONE   ctermfg=231  ctermbg=16

hi IncSearch      cterm=NONE   ctermfg=0    ctermbg=220
hi Search         cterm=NONE   ctermfg=0    ctermbg=220
hi ErrorMsg       cterm=BOLD   ctermfg=0    ctermbg=203
hi WarningMsg     cterm=BOLD   ctermfg=16   ctermbg=202
hi ModeMsg        cterm=BOLD   ctermfg=61   ctermbg=NONE
hi MoreMsg        cterm=BOLD   ctermfg=61   ctermbg=NONE
hi Question       cterm=BOLD   ctermfg=130  ctermbg=NONE

hi StatusLine     cterm=BOLD   ctermfg=247  ctermbg=235
hi User1          cterm=BOLD   ctermfg=46   ctermbg=235
hi User2          cterm=BOLD   ctermfg=63   ctermbg=235
hi StatusLineNC   cterm=NONE   ctermfg=244  ctermbg=235
hi VertSplit      cterm=NONE   ctermfg=244  ctermbg=235

hi WildMenu       cterm=BOLD   ctermfg=253  ctermbg=61

hi MBENormal                   ctermfg=247  ctermbg=235
hi MBEChanged                  ctermfg=253  ctermbg=235
hi MBEVisibleNormal            ctermfg=247  ctermbg=238
hi MBEVisibleChanged           ctermfg=253  ctermbg=238

hi DiffText       cterm=NONE   ctermfg=231  ctermbg=55
hi DiffChange     cterm=NONE   ctermfg=231  ctermbg=17
hi DiffDelete     cterm=NONE   ctermfg=231  ctermbg=52
hi DiffAdd        cterm=NONE   ctermfg=231  ctermbg=22

hi Folded         cterm=NONE   ctermfg=231  ctermbg=57
hi FoldColumn     cterm=NONE   ctermfg=63   ctermbg=232

hi Directory      cterm=NONE   ctermfg=46   ctermbg=NONE
hi LineNr         cterm=NONE   ctermfg=63   ctermbg=232
hi NonText        cterm=BOLD   ctermfg=63   ctermbg=NONE
hi SpecialKey     cterm=BOLD   ctermfg=135  ctermbg=NONE
hi Title          cterm=BOLD   ctermfg=124  ctermbg=NONE
hi Visual         cterm=NONE   ctermfg=231  ctermbg=61

hi Comment        cterm=NONE   ctermfg=220  ctermbg=NONE
hi Constant       cterm=NONE   ctermfg=215  ctermbg=NONE
hi String         cterm=NONE   ctermfg=215  ctermbg=234
hi Error          cterm=NONE   ctermfg=0    ctermbg=203
hi Identifier     cterm=NONE   ctermfg=203  ctermbg=NONE
hi Ignore         cterm=NONE
hi Number         cterm=NONE   ctermfg=203  ctermbg=NONE
hi PreProc        cterm=NONE   ctermfg=35   ctermbg=NONE
hi Special        cterm=NONE   ctermfg=135  ctermbg=NONE
hi SpecialChar    cterm=NONE   ctermfg=135  ctermbg=235
hi Statement      cterm=NONE   ctermfg=39   ctermbg=NONE
hi Todo           cterm=BOLD   ctermfg=160  ctermbg=NONE
hi Type           cterm=NONE   ctermfg=207  ctermbg=NONE
hi Underlined     cterm=BOLD   ctermfg=227  ctermbg=NONE
hi TaglistTagName cterm=BOLD   ctermfg=63   ctermbg=NONE

if v:version >= 700
    hi Pmenu          cterm=NONE  ctermfg=253 ctermbg=238
    hi PmenuSel       cterm=BOLD  ctermfg=253 ctermbg=61
    hi PmenuSbar      cterm=BOLD  ctermfg=253 ctermbg=63
    hi PmenuThumb     cterm=BOLD  ctermfg=253 ctermbg=63

    hi SpellBad       cterm=NONE  ctermbg=52
    hi SpellRare      cterm=NONE  ctermbg=53
    hi SpellLocal     cterm=NONE  ctermbg=58
    hi SpellCap       cterm=NONE  ctermbg=23
    hi MatchParen     cterm=NONE  ctermbg=14 ctermfg=35
endif

if v:version >= 703
    hi Conceal      cterm=NONE  ctermfg=135 ctermbg=NONE
    hi ColorColumn  cterm=NONE  ctermbg=235
endif


" git commit messages
hi diffRemoved    cterm=NONE   ctermfg=1    ctermbg=NONE
hi diffNewFile    cterm=NONE   ctermfg=1    ctermbg=NONE
hi diffAdded      cterm=NONE   ctermfg=2    ctermbg=NONE
hi diffFile       cterm=NONE   ctermfg=2    ctermbg=NONE

" Perl!
hi perlStringStartEnd    cterm=NONE  ctermfg=35  ctermbg=NONE

hi perlStatementControl  cterm=NONE  ctermfg=27  ctermbg=NONE
hi perlStatementInclude  cterm=NONE  ctermfg=27  ctermbg=NONE
hi perlRepeat            cterm=NONE  ctermfg=27  ctermbg=NONE
hi perlConditional       cterm=NONE  ctermfg=27  ctermbg=NONE
