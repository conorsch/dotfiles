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

# Configure Liquidprompt, only on interactive shells
if [[ $- = *i* ]] ; then
    # Make liquidprompt PS1 multiline.
    export LP_PS1_FILE="$HOME/.homesick/repos/liquidprompt/liquid_multiline.ps1"
    export LP_PS1_POSTFIX="\n $ "
    source ~/.liquidpromptrc
    source "$HOME/.homesick/repos/liquidprompt/liquidprompt"
fi

# Source alias/function files only if they haven't been loaded already,
# by checking whether a custom alias is found.
if ! type refresh > /dev/null 2>&1 ; then
    [[ -f ~/.bash_aliases ]] && source ~/.bash_aliases
    [[ -f ~/.bash_functions ]] && source ~/.bash_functions
fi

# source virtualenv wrappers, e.g. "workon"
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
if [[ -z "$VIRTUALENVWRAPPER_SCRIPT" ]] ; then
    # Prefer home dir path, more often up to date
    venv_script="$HOME/.local/bin/virtualenvwrapper.sh"
    if [[ -f "$venv_script" ]]; then
        source "$venv_script"
    fi
fi

# golang dev config
export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"
export PATH="$PATH:$GOBIN:/usr/local/go/bin"

# kubectl
#source <(kubectl completion bash)

# direnv
if hash direnv > /dev/null 2>&1; then
    eval "$(direnv hook bash)"
fi
