#####BEGIN ALIASES #####

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
alias l='ls -lsh'
alias ll='ls -lsh'
alias la='ls -lash'
alias lash='ls -lashR'
alias bi='beet import'
alias gits='git status'
alias gc='git commit'
alias gd='git diff -w' # ignore whitespace when displaying git diff
alias ga='git add'
alias gl="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --"
alias ack='ack-grep'
alias gh='github_browse'
alias pushall='git_push_all'
alias externalip='curl ifconfig.me'
alias internalip='hostname -I'
alias whereami='externalip | iploc'
alias whoshere='scan_local_ips' #alias to a Perl script in path, uses nmap;
alias wp='mwiki' #easier to remember for Wikipedia lookups
alias etym='etymology_lookup' #etymonline.com lookups via Perl script in ~/.bin
alias imdb='imdb_lookup' #etymonline.com lookups via Perl script in ~/.bin
alias refresh='source ~/.bashrc' #re-source bashrc easily
alias s='ssh -t s "tmux attach -d"'
alias stir='ssh -t s "tmux attach -d"'
alias t='ssh -t t "tmux attach -d"'
alias tepes='ssh -t t "tmux attach -d"'
alias killalljobs='kill -9 `jobs -p`'
alias fmac='format_mac_address' #re-format MAC address in readable way
alias kj='ssh kj' #ssh into king-james
alias makesilent="2>/dev/null"
alias speakertest="speaker-test -t wav -c 2" # test left and right stereo channels
alias onemonitor="xrandr --output VGA1 --off" # disconnect external monitor
alias therecanbeonlyone="onemonitor" # disconnect external monitor
alias gdns="echo 'nameserver 8.8.8.8' | sudo tee /etc/resolv.conf"
alias git="hub"
# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

