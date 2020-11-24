# If not running interactively, don't do anything
[[ -z "$PS1" ]] && return

[[ -f ~/.bashrc ]] && source ~/.bashrc
[[ -f ~/.bash_env_extra ]] && source ~/.bash_env_extra
[[ -z "SSH_CLIENT" ]] && source ~/.bin/ssh-agent-wrapper

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [[ -f /etc/bash_completion ]] && ! shopt -oq posix; then
    . /etc/bash_completion
fi
