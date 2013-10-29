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
    builtin cd "$@" && ls -lsh
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
    ssh -t 10.0.0.14 mocp
}
function strlength() { #print length of given string
    echo "$@" | awk '{ print length }'
}
function makeiso() { # create ISO from CD/DVD
    ISONAME=$@
    dd if=/dev/sr0 of="$ISONAME.iso"
}
function burniso() { # burn ISO to DVD
    ISONAME=$@
    growisofs -dvd-compat -Z /dev/sr0="$ISONAME"
}
function ackr () { # for all files containing regex1, perform substition via regex2
  ack-grep $1 -l | xargs perl -pi -E "$2"
}
function atb() {
    l=$(tar tf $1);
    if [ $(echo "$l" | wc -l) -eq $(echo "$l" | grep $(echo "$l" | head -n1) | wc -l) ];
        then tar xf $1;
    else mkdir ${1%.t(ar.gz||ar.bz2||gz||bz||ar)} &&
        tar xf $1 -C ${1%.t(ar.gz||ar.bz2||gz||bz||ar)};
    fi;
}
function disabletouchpad() {
    xinput list | grep TouchPad | perl -n -e 'm/id=(\d+)/g; `xinput --set-prop $1 "Synaptics Off" 1`;'
}
function formyeyes() {
    redshift -l `latlong` > /dev/null & # feed current location data into redshift;
}
