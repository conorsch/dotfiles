# If not running interactively, don't do anything
[[ -z "$PS1" ]] && return

[[ -f ~/.bashrc ]] && source ~/.bashrc
[[ -f ~/.bash_env_extra ]] && source ~/.bash_env_extra
if [[ -z "SSH_CLIENT" ]] ; then
    if ! printenv | grep -q ^QUBES_ ; then
        source ~/.bin/ssh-agent-wrapper
    fi
fi

# bash-completions
# kubectl
if hash kubectl > /dev/null 2>&1 ; then
    source <(kubectl completion bash)
fi
# direnv
if hash direnv > /dev/null 2>&1; then
    eval "$(direnv hook bash)"
fi

# golang/gvm
[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"

# virtualenv
if [[ -z "$VIRTUALENVWRAPPER_SCRIPT" ]] ; then
    # Prefer home dir path, more often up to date
    venv_script="$HOME/.local/bin/virtualenvwrapper.sh"
    if [[ -f "$venv_script" ]]; then
        source "$venv_script"
    fi
fi
