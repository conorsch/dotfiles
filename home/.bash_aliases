# Alias definitions.
alias l='ls -lsh'
alias ll='ls -lsh'

# global git aliases
alias gc='git commit'
alias gd='git diff'
alias ga='git add'
# pretty git logs
alias gl="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --"
# same as the above, but "plain" (better for redirecting STDOUT)
alias glp="git log --graph --pretty=format:'%h -%d %s (%cr) <%an>' --abbrev-commit --"
# same as the above, but all branches
alias gla="git log --graph --all --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --"
alias gits='git status'
alias gh='hub browse'

alias ipy='ipython --no-banner --no-confirm-exit -i'
alias vssh='vagrant ssh'

alias ack='ack-standalone'
alias refresh='source ~/.bash_profile' # re-source ENV easily (~/.bash_profile calls ~/.bashrc)
alias fmac='format_mac_address' #re-format MAC address in readable way
alias speakertest="speaker-test -t wav -c 2" # test left and right stereo channels
alias therecanbeonlyone="xrandr --output VGA1 --off" # disconnect external monitor
alias letmeknow='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
alias laptop-suspend='dbus-send --system --print-reply --dest="org.freedesktop.UPower" /org/freedesktop/UPower org.freedesktop.UPower.Suspend'

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Signal Chrome webapp.
alias signal-ows='/usr/bin/chromium-browser --profile-directory=Default --app-id=bikioccmkafdpakkkcpdbppfkghcmihk &'
