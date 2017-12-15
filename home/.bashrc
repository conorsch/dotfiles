# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# Madness. Utter madness. Leaving disabled by default.
if [ -n "$ONE_BASH_HISTORY_TO_RULE_THEM_ALL" ] ; then
    # Bash history config, so command history is shared across
    # multiple terminal windows, via http://unix.stackexchange.com/a/48113/16485
    export HISTCONTROL=ignoredups:erasedups  # no duplicate entries
    # Save and reload the history after each command finishes
    export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
fi

export HISTSIZE=100000                   # big big history
export HISTFILESIZE=100000               # big big history
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
# Make liquidprompt PS1 multiline
export LP_PS1_POSTFIX="\n $ "
