# Alias definitions.
alias l='ls -lsh'
alias ll='ls -lsh'
alias la='ls -lash'
alias lash='ls -lashR'
alias bi='beet import'

alias gc='git commit'
alias gd='git diff'
alias ga='git add'
alias gl="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --"
alias gits='git status'
alias gh='github_browse'
alias pushall='git_push_all'

alias ipy='ipython --no-banner --no-confirm-exit -i'
alias vssh='vagrant ssh'

alias ack='ack-standalone'
alias externalip='curl ifconfig.me'
alias internalip='hostname -I'
alias whereami='externalip | iploc'
alias whoshere='scan_local_ips' # alias to a Perl script in path, uses nmap;
#alias imdb='imdb_lookup' # broken IMDB lookups
alias refresh='source ~/.bash_profile' # re-source ENV easily (~/.bash_profile calls ~/.bashrc)
alias fmac='format_mac_address' #re-format MAC address in readable way
alias speakertest="speaker-test -t wav -c 2" # test left and right stereo channels
alias therecanbeonlyone="xrandr --output VGA1 --off" # disconnect external monitor
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi
