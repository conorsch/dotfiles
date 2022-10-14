# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs
PATH="$PATH:$HOME/.local/bin:$HOME/bin"
export PATH

# esc to caps lock
setxkbmap -option caps:escape
setxkbmap -option ralt:compose
setxkbmap -option compose:ralt
