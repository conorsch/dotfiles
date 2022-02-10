# If not running interactively, don't do anything
[[ -z "$PS1" ]] && return

[[ -f ~/.bashrc ]] && source ~/.bashrc
[[ -f ~/.bash_env_extra ]] && source ~/.bash_env_extra
if [[ -z "SSH_CLIENT" ]] ; then
    if ! printenv | grep -q ^QUBES_ ; then
        source ~/.bin/ssh-agent-wrapper
    fi
fi
