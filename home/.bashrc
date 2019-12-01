# If not running interactively, don't do anything
[ -z "$PS1" ] && return

shopt -s checkwinsize # check the window size after each command and, if necessary, update the values of LINES and COLUMNS.
shopt -s cdspell # correct typos when spelling out paths.
shopt -s cmdhist # multi-line commands are still entered into history
shopt -s histreedit # re-edit history substitution if command fails

# make less more friendly for non-text input files, see lesspipe(1)
# [ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/.bin"
export EDITOR="vim"
export BROWSER="firefox"
export GOPATH="$HOME/go"
# Set a single directory for storing ISOs used with Packer. Otherwise,
# the ISOs will always be pulled into a subdirectory of PWD, which can
# make for a lot of duplication.
export PACKER_CACHE_DIR="$HOME/.packer.d/cache"

# Dotfiles and PS1 config
if ! hash homeshick > /dev/null 2>&1 ; then
    source "$HOME/.homesick/repos/homeshick/homeshick.sh"
fi

# Make liquidprompt PS1 multiline.
export LP_PS1_FILE="$HOME/.homesick/repos/liquidprompt/liquid_multiline.ps1"
export LP_PS1_POSTFIX="\n $ "
source ~/.liquidpromptrc
source "$HOME/.homesick/repos/liquidprompt/liquidprompt"

[[ -z "SSH_CLIENT" ]] && source ~/.bin/ssh-agent-wrapper

# Source alias/function files only if they haven't been loaded already,
# by checking whether a custom alias is found.
if ! type refresh > /dev/null 2>&1 ; then
    [ -f ~/.bash_aliases ] && source ~/.bash_aliases
    [ -f ~/.bash_functions ] && . ~/.bash_functions
fi

# source virtualenv wrappers, e.g. "workon"
[[ -z "$VIRTUALENVWRAPPER_SCRIPT" ]] && source /usr/share/virtualenvwrapper/virtualenvwrapper.sh

# golang dev config
export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"
export PATH="$PATH:$GOBIN:/usr/local/go/bin"

[[ -e /etc/profile.d/bash_completion.sh ]] && source /etc/profile.d/bash_completion.sh

# kubectl
#source <(kubectl completion bash)

# direnv
if hash direnv > /dev/null 2>&1; then
    eval "$(direnv hook bash)"
fi
