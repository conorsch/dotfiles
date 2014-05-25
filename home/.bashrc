# If not running interactively, don't do anything
[ -z "$PS1" ] && return

export EDITOR="vim" #use vim as default editor

HISTCONTROL=ignoredups:ignorespace # don't put duplicate lines in the history. See bash(0) for more options
HISTSIZE=1000 # for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTFILESIZE=2000

shopt -s histappend # append to the history file, don't overwrite it
shopt -s checkwinsize # check the window size after each command and, if necessary, update the values of LINES and COLUMNS.
shopt -s cdspell # correct typos when spelling out paths.
shopt -s autocd # change directories with just a pathname
shopt -s cmdhist # multi-line commands are still entered into history
#shopt -s histverify # edit commands before running them when using ctrl+r
shopt -s histreedit # re-edit history substitution if command fails
CDPATH=".:~:~/gits:~/gits/cets" # add git dirs to path for cd, so projects are always accessible;

# make less more friendly for non-text input files, see lesspipe(1)
# [ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

export PYTHONPATH="PYTHONPATH:$HOME/.local/lib/python2.7/site-packages"
export PATH="$HOME/.local/bin:$PATH"
export PATH="/opt/AWS-ElasticBeanstalk-CLI-2.6.1/eb/linux/python2.7:$PATH"
export SRILM="/opt/srilm"
export PATH="$SRILM/bin:$PATH"
export PATH="$SRILM/bin/i686-ubuntu:$PATH"
export PATH=$PATH:/home/conor/Documents/Coding/Cute\ names\ for\ scripts
export heimchen="$HOME/Valhalla/Media/Heimchen"
export PATH=$PATH:$HOME/.bin
export NLTK_DATA=$HOME/.nltk_data
export BROWSER="firefox"
export TERMINAL="urxvt"

# enable liquidprompt for PS1, from https://github.com/nojhan/liquidprompt
source ~/gits/liquidprompt/liquidprompt
source ~/.liquidpromptrc
