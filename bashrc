# If not running interactively, don't do anything
[ -z "$PS1" ] && return

export EDITOR="vim" #use vim as default editor

# history options
HISTCONTROL=ignoredups:ignorespace # don't put duplicate lines in the history. See bash(0) for more options
HISTSIZE=1000 # for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTFILESIZE=2000

####BEGIN SHELL OPTIONS
shopt -s histappend # append to the history file, don't overwrite it
shopt -s checkwinsize # check the window size after each command and, if necessary, update the values of LINES and COLUMNS.
shopt -s cdspell # correct typos when spelling out paths.
shopt -s autocd # change directories with just a pathname
shopt -s cmdhist # multi-line commands are still entered into history
#shopt -s histverify # edit commands before running them when using ctrl+r
shopt -s histreedit # re-edit history substitution if command fails
CDPATH=".:~:~/gits:~/gits/cets" # add git dirs to path for cd, so projects are always accessible;
####END SHELL OPTIONS

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi
