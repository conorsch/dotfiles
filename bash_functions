editall() { # edit all files by file extension
     find . -type f -iname '*.'"$1" -and -not -iname '__init__*' -exec vim -p {} +
}
genpw() { # generate random 30-character password
    strings /dev/urandom | grep -o '[[:alnum:]]' | head -n 30 | tr -d '\n'; echo
}
ackr() { # for all files matching regex1, perform in-place substition with regex2
    ack-grep $1 -l | xargs perl -pi -E "$2"
}
wp() { #short wikipedia entries from DNS query
    dig +short txt "$*".wp.dg.cx
}
formyeyes() { # enable redshift at this geographic location (IP-based);
    redshift -l `latlong` > /dev/null & # feed current location data into redshift;
}
touchpad() {
    trackpad_id=`xinput list | grep TouchPad | perl -ne 'm/id=(\d+)/g; print $1'`

    case "$1" in
        "")
           echo "Usage: touchpad [on|off]"
           RETVAL=1
           ;;
        on)
           trackpad_state=0
           ;;
        off)
           trackpad_state=1
           ;;
    esac

    xinput --set-prop $trackpad_id "Synaptics Off" $trackpad_state
}
extr_mp3() { 
    ffmpeg -i "$1" -f mp4 -ar 44100 -ac 2 -ab 192k -vn -y -acodec copy "$1.mp3"
}
top10() {
    history | awk '{a[$2]++}END{for(i in a){print a[i] " " i}}' | sort -rn | head
}
sharefile() { #spin up a temporary webserver to serve target file for one HTTP GET
    FILE=$1
    PORT=$2 || 80
    echo "Currently sharing file '$1'. This file will only be available for one transfer."
    ADDRESS_IP="http://$(hostname -I | sed 's/ //g')/$FILE" #grab local IP and build URL for it (also remove trailing space)
    echo "File will be available on the local network at: 
    $ADDRESS_IP" #provide URL where target file is accessible
    sudo nc -v -l $PORT < "$FILE" #call netcat to host file on port 80
}
rnum() {
    echo $(( $RANDOM % $@ ))
}
iploc() { #Find geographic location of an IP address
    lynx -dump http://www.ip-adress.com/ip_tracer/?QRY=$1 | \
        grep address | \
        egrep 'city|state|country' | \
        awk '{print $3,$4,$5,$6,$7,$8}' | \
        sed 's\ip address flag \\' | \
        sed 's\My\\'
}
ugrep() { #look up Unicode characters by name
    egrep -i "^[0-9a-f]{4,} .*$*" $(locate CharName.pm) | while read h d; do /usr/bin/printf "\U$(printf "%08x" 0x$h)\tU+%s\t%s\n" $h "$d"; done
}

scan_host() { #use nmap to find open ports on a given IP address;
    sudo nmap -sS -P0 -sV -O $@
}
canhaz() {
    sudo aptitude -y install $@
}
getem() {
    sudo aptitude update
    sudo aptitude -y safe-upgrade
}
journal() {
    lowriter ~/Documents/Journal.odt
}
slg() {
    tail -f -n 25 /var/log/syslog
}
newestfiles() {
    #Ignores all git and subversion files/directories, because who wants to sort those?
    #Date statement could be cleaner, though; gets ugly on long filenames
    find "$@" -not -iwholename '*.svn*' -not -iwholename '*.git*' -type f -print0 | xargs -0 ls -l --time-style='+%Y-%m-%d_%H:%M:%S' | sort -k 6 | tail -n 10
}
explodeavi() {
    ffmpeg -i "$@" -f image2 image-%03d.jpg
}
resetconnection() {
    sudo nmcli nm wifi off
    sleep 5
    sudo nmcli nm wifi on
}
giveroot() {
    sudo usermod -aG sudo $@
}
toritup() {
    ssh -f -2 -N -L 127.0.0.1:9049:127.0.0.1:9050 w 
}
rsyncssh() {
    rsync -e "ssh" -avPh $@
}
cd() {
    builtin cd "$@" && ls -lsh
}
muzik() {
    if [ -d /home/conor/Valhalla/Media/Heimchen ]; then
        mocp
    else 
        gjallar
        mocp
    fi
}
f() { #Abbreviated find command. Assumes cwd as target, and ignores version control files.
    find . -not -iwholename '*.svn*' -not -iwholename '*.git*' -iname "*$@*"
}
tssh() { #Connect to many machines via SSH by invoking tmux;
    declare -a HOSTS=$@ #Necessary to rename array due to quoting quirks
    tmux new "ssh-everywhere.sh $HOSTS" #Open new tmux session by calling script;
}
afterdownload() { #complete action after a download or transfer completes
    while [ -e $1 ] #$1 should be (hidden) partial file for download
        do sleep 1 #wait, check again
    done
    "$2" #perform designated action, supplied as second argument
}
pbar() { #run pianobar (Pandora.com client) on home desktop, connected to stereo
    ssh -t s "cd ~/gits/pianobar && ./pianobar"
}
stereo() { #plays audio file on computer connected to stereo;
    cat "$@" | ssh s "mplayer -cache 10000 -cache-min 1 - "
}
speaks() { #open mocp on home computer
    ssh -t 10.0.0.14 mocp
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
atb() {
    l=$(tar tf $1);
    if [ $(echo "$l" | wc -l) -eq $(echo "$l" | grep $(echo "$l" | head -n1) | wc -l) ];
        then tar xf $1;
    else mkdir ${1%.t(ar.gz||ar.bz2||gz||bz||ar)} &&
        tar xf $1 -C ${1%.t(ar.gz||ar.bz2||gz||bz||ar)};
    fi;
}
#### SILLY ####
matrix() {
    for t in "Wake up" "The Matrix has you" "Follow the white rabbit" "Knock, knock"
        do pv -qL10 <<<$'\e[2J'$'\e[32m'$t$'\e[37m'
        sleep 5
    done
    reset
}
starwars() {
    telnet towel.blinkenlights.nl
}
nyancat() {
    telnet miku.acm.uiuc.edu
}
#### SILLY ####

