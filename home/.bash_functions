#!/bin/bash
mute-commercial() {
   amixer -q -D pulse set Master toggle
   # Support custom sleep time via $1.
   sleep "${1:-30}"
   amixer -q -D pulse set Master toggle
}

git() {
   # Credit: http://unix.stackexchange.com/a/97958/16485
   local tmp=$(mktemp)
   local repo_name

   if [ "$1" = clone ] ; then
     /usr/bin/git "$@" 2>&1 | tee $tmp
     repo_name=$(perl -nE $'m/Cloning into \'([\w_-]+)\'.{3}$/ and print $1;' $tmp)
     rm $tmp
     printf "changing to directory %s\n" "$repo_name"
     cd "$repo_name"
   else
     /usr/bin/git "$@"
   fi
}

gmru() {
    # List all recently used branches within a git repo.
    # Mnemonic: "git most recently used"
    git for-each-ref --count="${1:-10}" \
        --sort=-committerdate refs/heads/ \
        --format='%(committerdate:relative) %09 %(objectname:short) %09 %(refname:short) %09 %(authorname)'
}
vagrant-all() { # pass cmd to all vagrant boxes
     for vm in $(vagrant status | cut -d' ' -f 1 | grep -Poz '(?s)\s{2}^(.*)\s{2}' | sed '/^$/d'); do
         vagrant $@ $vm
     done
}

set-desktop-background() { # assumes GNOME
    local img=$(readlink --canonicalize-existing "$1")
    gsettings set org.gnome.desktop.background picture-uri "file://${img}"
}

vagrant-update-all-boxes() {
# Update all hosted boxes. Omit boxes with version ', 0', since that
# likely indicates a manually added box, that can't be polled for updates.
    vagrant box list | grep -vP ', 0\)$' \
        | perl -lane 'print $F[0]' \
        | sort | uniq \
        | xargs -n1 vagrant box update --box
}
latlong() { # return latitude and longitude,colon-separated }
    curl http://ipinfodb.com 2>/dev/null | perl -0777 -nE \
        'm/Latitude : (-?\d+\.\d+).+?Longitude : (-?\d+\.\d+)/ms; \
        say "$1:$2" if $1 and $2'
}
editall() { # edit all files by file extension
     find . -type f -iname '*.'"$1" -and -not -iname '__init__*' -exec vim -p {} +
}
noscrob() { # disable lastfm scrobbling while practicing music
     sudo service lastfmsubmitd stop &&\
     muzik &&\
     sudo service lastfmsubmitd start
}
genpw() { # generate a diceware passphrase, failover to random str
    if hash diceware 2>/dev/null; then
        local wordcount
        wordcount=9
        if hash xclip 2>/dev/null; then
            diceware "$@" -n $wordcount | tee >(xclip -selection clipboard)
        else
            diceware "$@" -n $wordcount
        fi
    else # generate random 30-character password
        strings /dev/urandom | grep -o '[[:alnum:]]' | head -n 30 | tr -d '\n'; echo
    fi
}
ackr() { # for all files matching regex1, perform in-place substition with regex2
    ack-grep $1 -l | xargs perl -pi -E "$2"
}
gethtmlformfields() { # spit out list of HTML form field "name"s
    perl -nE $'/name=[\'"](\w+)[\'"]/; say $1 if $1;' "$1" | awk '!x[$0]++'
}
formyeyes() { # enable redshift at this geographic location (IP-based);
    redshift -l $(latlong) > /dev/null & # feed current location data into redshift;
}
top10() {
    # most commonly used shell commands
    history | awk '{a[$2]++}END{for(i in a){print a[i] " " i}}' | sort -rn | head
}
rnum() {
    echo $(( $RANDOM % $@ ))
}
canhaz() {
    sudo aptitude -y install $@
}
getem() {
    sudo apt update \
        && sudo apt dist-upgrade -y --auto-remove --purge
}
slg() {
    tail -f -n 25 /var/log/syslog
}
newestfiles() {
    #Ignores all git and subversion files/directories, because who wants to sort those?
    #Date statement could be cleaner, though; gets ugly on long filenames
    find "$@" -not -iwholename '*.svn*' -not -iwholename '*.git*' -type f -print0 | xargs -0 ls -l --time-style='+%Y-%m-%d_%H:%M:%S' | sort -k 6 | tail -n 10
}
muzik() {
    if [ -d "$heimchen" ]; then
        mocp
    else 
        gjallar
        mocp
    fi
}
f() { #Abbreviated find command. Assumes cwd as target, and ignores version control files.
    find . -not -iwholename '*.svn*' -not -iwholename '*.git*' -iname "*$@*"
}
strlength() { #print length of given string
    echo "$@" | awk '{ print length }'
}
makeiso() { # create ISO from CD/DVD
    ISONAME=$@
    dd if=/dev/sr0 of="$ISONAME.iso"
}
burniso() { # burn ISO to DVD
    ISONAME=$@
    growisofs -dvd-compat -Z /dev/sr0="$ISONAME"
}
gb() { # ultra git-blame
    git ls-tree -r -z --name-only HEAD -- $1 | xargs -0 -n1 git blame \
         --line-porcelain HEAD |grep  "^author "|sort|uniq -c|sort -nr
}
# Signal Chrome webapp.
signal_ows() {
    local signal_app_id="bikioccmkafdpakkkcpdbppfkghcmihk"
    nohup /usr/bin/chromium-browser --profile-directory=Default --app-id="${signal_app_id}" "$@" &
}
