source ~/.bashrc

if [[ -f ~/.bash_env_secure ]]; then
    source ~/.bash_env_secure
fi

export PYTHONPATH="PYTHONPATH:$HOME/.local/lib/python2.7/site-packages"
export PATH="$HOME/.local/bin:$PATH"
export PATH="/opt/AWS-ElasticBeanstalk-CLI-2.6.1/eb/linux/python2.7:$PATH"
export SRILM="/opt/srilm"
export PATH="$SRILM/bin:$PATH"
export PATH="$SRILM/bin/i686-ubuntu:$PATH"

# configure local Ruby gem support
if which ruby >/dev/null && which gem >/dev/null; then
    export PATH="$(ruby -rubygems -e 'puts Gem.user_dir')/bin:$PATH"
    export GEM_HOME="$(ruby -rubygems -e 'puts Gem.user_dir')"
fi

if [ -f ~/.bash_aliases ]; then # source bash_aliases file if it exists
    . ~/.bash_aliases
fi

if [ -f ~/.bash_functions ]; then # source bash_functions file if it exists
    . ~/.bash_functions
fi

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

# enable liquidprompt for PS1, from https://github.com/nojhan/liquidprompt
source ~/gits/liquidprompt/liquidprompt
source ~/.liquidpromptrc

export PATH=$PATH:/home/conor/Documents/Coding/Cute\ names\ for\ scripts
export heimchen="$HOME/Valhalla/Media/Heimchen"
export PATH=$PATH:$HOME/.bin
export NLTK_DATA=$HOME/.nltk_data
export BROWSER="firefox"