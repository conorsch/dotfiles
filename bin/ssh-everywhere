#!/bin/bash
#ssh-everywhere.sh #credit to http://www.christoph-egger.org/weblog/entry/33
#This script takes hostnames as arguments (aliases from ~/.ssh/config are OK) 
#and opens SSH sessions to them in separate, synchronized tmux panes

#It's strongly recommended to invoke this script with a bashrc function, e.g.:
#function tssh() { #Connect to many machines via SSH by invoking tmux;
#    declare -a HOSTS=$@ #Necessary to rename array due to quoting quirks
#    tmux new "ssh-everywhere.sh $HOSTS" #Open new tmux session by calling script;
#}
#Note that this script must be added to PATH in order for this to work.
#If anyone can figure out how to integrate this functionality entirely in bashrc,
#please do let me know!

for host in $@
do
  tmux splitw "ssh $host"
  tmux select-layout tiled
done
tmux set-window-option synchronize-panes on
