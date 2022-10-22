# If not running interactively, don't do anything
[[ -z "$PS1" ]] && return

shopt -s checkwinsize # check the window size after each command and, if necessary, update the values of LINES and COLUMNS.
shopt -s cdspell # correct typos when spelling out paths.
shopt -s cmdhist # multi-line commands are still entered into history
shopt -s histreedit # re-edit history substitution if command fails

export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/bin"
export EDITOR="vim"
export BROWSER="firefox"

# Dotfiles and PS1 config
if ! hash homeshick > /dev/null 2>&1 ; then
    source "$HOME/.homesick/repos/homeshick/homeshick.sh"
fi

# Set caps lock to Escape
if hash setxkbmap > /dev/null 2>&1 ; then
    setxkbmap -option caps:escape
    setxkbmap -option ralt:compose
    setxkbmap -option compose:ralt
fi

# Configure PS1, only on interactive shells
if [[ $- = *i* ]] ; then
    # Starship shell prompt
    if hash starship > /dev/null 2>&1 ; then
        eval "$(starship init bash)"
    fi
else
    # Don't continue if shell is non-interactive
    return
fi

# Source alias/function files only if they haven't been loaded already,
# by checking whether a custom alias is found.
if ! type refresh > /dev/null 2>&1 ; then
    [[ -f ~/.bash_aliases ]] && source ~/.bash_aliases
    [[ -f ~/.bash_functions ]] && source ~/.bash_functions
    [[ -f ~/.bash_profile ]] && source ~/.bash_profile
fi

# source virtualenv wrappers, e.g. "workon"
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3

# golang dev config
export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"
export PATH="$PATH:$GOBIN:/usr/local/go/bin"
export GO111MODULE=on

# Experimental new docker build system, prettier and slightly faster
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# Default byobu config screws up vim colors, override.
if [[ -n "$BYOBU_TERM" ]]; then
    export BYOBU_TERM=xterm-256color
    export TERM=$BYOBU_TERM
    export BYOBU_PYTHON=python3
fi

# Forcing terminal setting, because vim colorscheme fails with "TERM=alacritty".
# Might need to switch to neovim finally.
export TERM=xterm-256color

# rustlang dev config
. "$HOME/.cargo/env"
