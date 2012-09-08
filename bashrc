# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

export EDITOR="vim" #use vim as default editor

#history options
HISTCONTROL=ignoredups:ignorespace #don't put duplicate lines in the history. See bash(1) for more options
HISTSIZE=1000 #for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTFILESIZE=2000

####BEGIN SHELL OPTIONS
shopt -s histappend # append to the history file, don't overwrite it
shopt -s checkwinsize #check the window size after each command and, if necessary, update the values of LINES and COLUMNS.
shopt -s cdspell #this corrects typos when spelling out paths.
shopt -s autocd #change directories with just a pathname
shopt -s cmdhist #Multi-line commands are still entered into history
####END SHELL OPTIONS

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

case "$TERM" in #set a fancy prompt (non-color, unless we know we "want" color)
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

#export tmuxinator projects for tab-completion of session names
[[ -s $HOME/.tmuxinator/scripts/tmuxinator ]] && source $HOME/.tmuxinator/scripts/tmuxinator

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

#####BEGIN ALIASES #####

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
alias l='ls -lsh'
alias ll='ls -lsh'
alias la='ls -lash'
alias rsync='rsync -avPh'
alias bi='beet import'
alias gits='git status'
alias gc='git commit'
alias gd='git diff'
alias ga='git add'
alias ack='ack-grep'
alias gh='github_browse'
alias pushall='git_push_all'
alias externalip='curl ifconfig.me'
alias internalip='hostname -I'
alias whereami='externalip | iploc'
alias whoshere='scan_local_ips' #alias to a Perl script in path, uses nmap;
alias wp='mwiki' #easier to remember for Wikipedia lookups
alias etym='etymology_lookup' #etymonline.com lookups via Perl script in ~/.bin
alias refresh='source ~/.bashrc' #re-source bashrc easily
alias s='ssh -t s "tmux attach -d"'
alias stir='ssh -t s "tmux attach -d"'
alias t='ssh -t t "tmux attach -d"'
alias tepes='ssh -t t "tmux attach -d"'
# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

if [ -f ~/.bash_aliases ]; then #source bash_aliases file if it exists
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

export PATH=$PATH:/home/conor/Documents/Coding/Cute\ names\ for\ scripts
export heimchen="/home/conor/Valhalla/Media/Heimchen"
export PATH=$PATH:/home/conor/.bin
export makesilent="2>/dev/null"
#export PATH="${PATH}$(find /home/conor/githubrepos -name '.*' -prune -o -type d -printf ':%p')"
#export PATH=$PATH:$(find /home/conor/githubrepos -type d | sed '/\/./d' | tr '\n' ':' | sed 's/:$//') 

#####BEGIN borrowed tips
function matrix(){
    for t in "Wake up" "The Matrix has you" "Follow the white rabbit" "Knock, knock";do pv -qL10 <<<$'\e[2J'$'\e[32m'$t$'\e[37m';sleep 5;done;reset
}
extr_mp3(){ 
    ffmpeg -i "$1" -f mp4 -ar 44100 -ac 2 -ab 192k -vn -y -acodec copy "$1.mp3"
}
starwars(){
    telnet towel.blinkenlights.nl
}
nyancat(){
    telnet miku.acm.uiuc.edu
}
top10(){
    history | awk '{a[$2]++}END{for(i in a){print a[i] " " i}}' | sort -rn | head
}
sharefile(){ #spin up a temporary webserver to serve target file for one HTTP GET
    FILE=$1
    PORT=$2 || 80
    echo "Currently sharing file '$1'. This file will only be available for one transfer."
    ADDRESS_IP="http://$(hostname -I | sed 's/ //g')/$FILE" #grab local IP and build URL for it (also remove trailing space)
    echo "File will be available on the local network at: 
    $ADDRESS_IP" #provide URL where target file is accessible
    sudo nc -v -l $PORT < "$FILE" #call netcat to host file on port 80
}
rnum(){
    echo $(( $RANDOM % $@ ))
}
#md () { #causing problems on some machines, disabling for now;
#    mkdir -p "$@" && cd "$@"; 
#}
function iploc() { #Find geographic location of an IP address
    lynx -dump http://www.ip-adress.com/ip_tracer/?QRY=$1 | \
        grep address | \
        egrep 'city|state|country' | \
        awk '{print $3,$4,$5,$6,$7,$8}' | \
        sed 's\ip address flag \\' | \
        sed 's\My\\'
}
function weather() { #grab weather via Yahoo! weather APIs; lynx would be more portable than elinks
    zipcode="$@"
    elinks -dump "http://weather.yahooapis.com/forecastrss?p=${zipcode}" | grep -A 4 "Current "
}
function mwiki() { #short wikipedia entries from DNS query
    dig +short txt "$*".wp.dg.cx
    }
function genpw() { #generate random 30-character password
    strings /dev/urandom | grep -o '[[:alnum:]]' | head -n 30 | tr -d '\n'; echo
}
function ugrep() { #look up Unicode characters by name
    egrep -i "^[0-9a-f]{4,} .*$*" $(locate CharName.pm) | while read h d; do /usr/bin/printf "\U$(printf "%08x" 0x$h)\tU+%s\t%s\n" $h "$d"; done
}
cd() { #Print working directory after a cd.
    if [[ $@ == '-' ]]; then
        builtin cd "$@" > /dev/null  # We'll handle pwd.
    else
        builtin cd "$@"
    fi
    echo -e "   \033[1;30m"`pwd`"\033[0m"
}
function scan_host() { #use nmap to find open ports on a given IP address;
    sudo nmap -sS -P0 -sV -O $@
}
#####END borrowed tips


function canhaz(){
    sudo aptitude -y install $@
}
function getem(){
    sudo aptitude update
    sudo aptitude -y safe-upgrade
}
function journal(){
    lowriter ~/Documents/Journal.odt
}
function slg(){
    tail -f -n 25 /var/log/syslog
}
function newestfiles(){
    #Ignores all git and subversion files/directories, because who wants to sort those?
    #Date statement could be cleaner, though; gets ugly on long filenames
    find "$@" -not -iwholename '*.svn*' -not -iwholename '*.git*' -type f -print0 | xargs -0 ls -l --time-style='+%Y-%m-%d_%H:%M:%S' | sort -k 6 | tail -n 10
}
function explodeavi(){
    ffmpeg -i "$@" -f image2 image-%03d.jpg
}
function resetconnection() {
    sudo nmcli nm wifi off
    sleep 5
    sudo nmcli nm wifi on
}
function giveroot(){
    sudo usermod -aG sudo $@
}
function toritup() {
    ssh -f -2 -N -L 127.0.0.1:9049:127.0.0.1:9050 w 
}
function rsyncssh() {
    rsync -e "ssh" -avPh $@
}
function cd() {
    builtin cd $@ && ls -lsh
}
function muzik() {
    if [ -d /home/conor/Valhalla/Media/Heimchen ] 
        then
            mocp
    else 
       gjallar
       mocp
    fi
}
function cdls() { 
    cd $1 
    ll
}
function splittracks() {
    echo "Attempting to split audio tracks now... "
    rename -v 's/ /_/g' *
    cuebreakpoints $1 | shnsplit -o flac $2
    cuetag $1 split-track*
    echo "All done!"
}
function f() { #Abbreviated find command. Assumes cwd as target, and ignores version control files.
    find . -not -iwholename '*.svn*' -not -iwholename '*.git*' -iname "*$@*"
}
function tssh() { #Connect to many machines via SSH by invoking tmux;
    declare -a HOSTS=$@ #Necessary to rename array due to quoting quirks
    tmux new "ssh-everywhere.sh $HOSTS" #Open new tmux session by calling script;
}

#set -o vi #Set vi input mode (instead of default emacs style)
function g() { 
    lynx -dump "http://google.com/search?q=$*" | less
}
function afterdownload() { #complete action after a download or transfer completes
    while [ -e $1 ] #$1 should be (hidden) partial file for download
        do sleep 1 #wait, check again
    done
    "$2" #perform designated action, supplied as second argument
}
function pbar() { #run pianobar (Pandora.com client) on home desktop, connected to stereo
    ssh -t s "cd ~/gits/pianobar && ./pianobar"
}
function stereo() { #plays audio file on computer connected to stereo;
    cat "$@" | ssh s "mplayer -cache 10000 -cache-min 1 - "
}
function speaks() { #open mocp on home computer
    ssh -t s mocp
}

function strlength() { #print length of given string
    echo "$@" | awk '{ print length }'
}

#### GIT #####
function git_prompt_status() { # for future use, from oh my zsh
  local index=$(git status --porcelain 2> /dev/null)
  local gitstatus=""

  if $(echo "$index" | grep '^?? ' &> /dev/null); then
gitstatus="$gitstatus"
  fi

if $(echo "$index" | grep '^A ' &> /dev/null); then
gitstatus="$gitstatus"
  elif $(echo "$index" | grep '^M ' &> /dev/null); then
gitstatus="$gitstatus"
  fi

if $(echo "$index" | grep '^ M ' &> /dev/null); then
gitstatus="$gitstatus"
  elif $(echo "$index" | grep '^AM ' &> /dev/null); then
gitstatus="$gitstatus"
  elif $(echo "$index" | grep '^ T ' &> /dev/null); then
gitstatus="$gitstatus"
  fi

if $(echo "$index" | grep '^R ' &> /dev/null); then
gitstatus="$gitstatus"
  fi

if $(echo "$index" | grep '^ D ' &> /dev/null); then
gitstatus="$gitstatus"
  elif $(echo "$index" | grep '^AD ' &> /dev/null); then
gitstatus="$gitstatus"
  fi

if $(echo "$index" | grep '^UU ' &> /dev/null); then
gitstatus="$gitstatus"
  fi

echo "$gitstatus"
}

function get_git_branch {
  echo $(__git_ps1 "%s")
}

function get_git_remote {
  echo $(git config --get branch.$branch.remote)
}

function parse_git_unpushed {
  # Check first for branch remote
  local branch=`get_git_branch`
  local remote=`get_git_remote`
  local unpublished=`__git_refs | grep $remote/$branch`
  if [[ "$unpublished" == "" ]]; then
    # No remote
    echo -e "\001\033[1;31m\002\xE2\x9C\xAA"
  else
    # Check if we've pushed to remote
    if [[ $remote != "" ]]; then
local unpushed=`/usr/bin/git cherry -v $remote/$branch`
    else
local unpushed=`/usr/bin/git cherry -v origin/$branch`
    fi
if [[ "$unpushed" != "" ]]; then
      # Unpushed
      echo -e "\001\033[1;31m\002\xE2\x9A\xA1"
    else
      # Pushed
      echo -e "\001\033[1;32m\002\xE2\x9D\x80\001\033[0m\002"
    fi
fi
}

parse_git_dirty() {
  if [[ -n $(git status -s 2> /dev/null) ]]; then
echo -e "\001\033[1;31m\002\xE2\x9C\x97\001\033[0m\002"
  else
local thing=1
  fi
}

function parse_git_branch {
  local branch=`get_git_branch`
  local remote=`get_git_remote`

  if [[ $branch != "" && $remote != "" && $remote != "origin" ]]; then
branch="$remote\001\033[1;34m\002/\001\033[1;33m\002$branch"
  fi

  [[ $branch ]] && echo -e "[\001\033[1;33m\002$branch$(parse_git_dirty)$(parse_git_unpushed)\001\033[0m\002] "
}

export PS1='( \! ) \u@\h{ \w } $(parse_git_branch): ' #( history ) user@hostname{ cwd } sigil:
