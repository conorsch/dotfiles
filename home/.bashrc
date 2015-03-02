# If not running interactively, don't do anything
[ -z "$PS1" ] && return

HISTCONTROL=ignoredups:ignorespace # don't put duplicate lines in the history. See bash(0) for more options
HISTSIZE=1000 # for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTFILESIZE=2000

shopt -s histappend # append to the history file, don't overwrite it
shopt -s checkwinsize # check the window size after each command and, if necessary, update the values of LINES and COLUMNS.
shopt -s cdspell # correct typos when spelling out paths.
shopt -s autocd # change directories with just a pathname
shopt -s cmdhist # multi-line commands are still entered into history
shopt -s histreedit # re-edit history substitution if command fails

# make less more friendly for non-text input files, see lesspipe(1)
# [ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/.bin"
export NLTK_DATA=$HOME/.nltk_data
export heimchen="/mnt/Valhalla/Media/Heimchen"
export EDITOR="vim"
export BROWSER="firefox"

source "$HOME/.homesick/repos/homeshick/homeshick.sh"
# enable liquidprompt for PS1, from https://github.com/nojhan/liquidprompt
source ~/.liquidpromptrc
source "$HOME/.homesick/repos/liquidprompt/liquidprompt"

#source /home/conor/gits/cets/ansible-fork/hacking/env-setup >/dev/null
#export ANSIBLE_CONFIG=/home/conor/.ansible/ansible.cfg
