source ~/.bashrc

[[ -z "SSH_CLIENT" ]] && source ~/.bin/ssh-agent-wrapper
[[ -f ~/.bash_env_secure ]] && source ~/.bash_env_secure

# configure local Ruby gem support
#if which ruby >/dev/null && which gem >/dev/null; then
#    export PATH="$(ruby -rubygems -e 'puts Gem.user_dir')/bin:$PATH"
#    export GEM_HOME="$(ruby -rubygems -e 'puts Gem.user_dir')"
#fi

# configure rvm support
# commented out so it's not always on
# export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
# [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

# source bash_aliases file if it exists
[ -f ~/.bash_aliases ] && source ~/.bash_aliases

# source bash_functions file if it exists
[ -f ~/.bash_functions ] && . ~/.bash_functions

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

case "$TERM" in # set a fancy prompt (non-color, unless we know we "want" color)
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

# export tmuxinator projects for tab-completion of session names
[[ -s $HOME/.tmuxinator/scripts/tmuxinator ]] && source $HOME/.tmuxinator/scripts/tmuxinator
# source virtualenv wrappers, e.g. "workon"
which virtualenvwrapper.sh > /dev/null && source $(which virtualenvwrapper.sh)
