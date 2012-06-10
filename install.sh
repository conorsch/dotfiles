#!/bin/sh
#Script for setting up a new computer with familiar dotfiles by symlinking.
#Original author unknown; this script taken from https://github.com/jsantell/home
cutstring="DO NOT EDIT BELOW THIS LINE"

for name in *; do #Look at all files in current directory (*)
  target="$HOME/.$name" #name 'target' as file from current directory, with ~/ preprended
  if [ -e "$target" ]; then #if target file alrady exists
    if [ ! -L "$target" ]; then #and if target file is not a symlink
      cutline=`grep -n -m1 "$cutstring" "$target" | sed "s/:.*//"` #search target file for "cutstring" (is target this script?)
      if [ -n "$cutline" ]; then #if cutline is NOT empty
	    cutline=$((cutline-1))
        echo "Updating $target" #Provide feedback 
        head -n $cutline "$target" > update_tmp
        startline=`sed '1!G;h;$!d' "$name" | grep -n -m1 "$cutstring" | sed "s/:.*//"`
        if [ -n "$startline" ]; then
          tail -n $startline "$name" >> update_tmp
        else
          cat "$name" >> update_tmp #prepare temporary file with contents of target file
        fi
        mv update_tmp "$target" #move temporary file to ~/, renaming it appropriately.
      else #if cutline string IS empty (see declaration above) 
        echo "WARNING: $target exists but is not a symlink." #state that clobbering would happen, stop;
      fi
    fi
  else
    if [ "$name" != 'install.sh' ]; then #if target script is NOT this script ("install.sh")
      echo "Creating $target" #provide feedback to user
      if [ -n "$(grep "$cutstring" "$name")" ]; then
        cp "$PWD/$name" "$target" #copy target script to ~/ (see 'target' declaration above)
      else
        ln -s "$PWD/$name" "$target" #create symlink for target script instead of copying it.
      fi
    fi
  fi
done
