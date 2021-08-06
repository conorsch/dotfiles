# Alias definitions.
alias l='ls -lsh'
alias ll='ls -lsh'

alias apb="ansible-playbook --diff"

# global git aliases
alias gc='git commit'
alias gd='git diff'
alias ga='git add'
alias gits='git status'

alias dcd="doctl compute droplet"

# pretty git logs
alias gl="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --"
# same as the above, but "plain" (better for redirecting STDOUT)
alias glp="git log --graph --pretty=format:'%h -%d %s (%cr) <%an>' --abbrev-commit --"
# same as the above, but all branches
alias gla="git log --graph --all --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --"
alias gh='hub browse'

alias ipy='ipython --no-banner --no-confirm-exit -i'

alias refresh='source ~/.bash_profile' # re-source ENV easily (~/.bash_profile calls ~/.bashrc)
alias laptop-suspend='dbus-send --system --print-reply --dest="org.freedesktop.UPower" /org/freedesktop/UPower org.freedesktop.UPower.Suspend'

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# YAML/JSON helpers
alias yaml2json="python3 -c 'import sys, yaml, json; y=yaml.load(sys.stdin.read()); print(json.dumps(y, indent=2))'"
alias yamlfix="python3 -c 'import sys, yaml; y=yaml.load(sys.stdin.read()); print(yaml.dump(y, indent=2))'"

# bootstrap dev langs
# https://rustup.rs/
alias get-rust="curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"

alias dark-mode="high-dpi"
alias light-mode="high-dpi light"
