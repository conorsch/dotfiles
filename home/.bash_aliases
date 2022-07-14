# Alias definitions.

# global git aliases
alias gc='git commit'
alias gd='git diff'
alias ga='git add'
alias gits='git status'

# pretty git logs
alias gl="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --"
# same as the above, but "plain" (better for redirecting STDOUT)
alias glp="git log --graph --pretty=format:'%h -%d %s (%cr) <%an>' --abbrev-commit --"
# same as the above, but all branches
alias gla="git log --graph --all --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --"

alias ipy='ipython --no-banner --no-confirm-exit -i'

alias refresh='source ~/.bash_profile' # re-source ENV easily (~/.bash_profile calls ~/.bashrc)

alias dcd="doctl compute droplet"

# YAML/JSON helpers
alias yaml2json="python3 -c 'import sys, yaml, json; y=yaml.load(sys.stdin.read()); print(json.dumps(y, indent=2))'"
alias yamlfix="python3 -c 'import sys, yaml; y=yaml.load(sys.stdin.read()); print(yaml.dump(y, indent=2))'"

# bootstrap dev langs
# https://rustup.rs/
alias get-rust="curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"

alias dark-mode="terminal-config"
alias light-mode="terminal-config light"

alias ll="exa -l"
alias tree="exa -l -R --tree"
