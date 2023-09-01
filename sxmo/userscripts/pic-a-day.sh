#!/bin/bash
# title="$icon_img Pic A Day"

file=$(ls ~/Pictures | sxmo_dmenu.sh -p "File")
newfile=$(echo -e "Now\n01-01-1970 00-00 PM.jpeg" | sxmo_dmenu_with_kb.sh -p "New Filename")

if [ "$newfile" = "Now" ]; then
  mv ~/Pictures/"$file" ~/"$(date +"%d-%m-%Y %H-%M %p.jpeg")"
  newfile="$(date +"%d-%m-%Y %H-%M %p.jpeg")"
else
  mv ~/Pictures/"$file" ~/"$newfile"
fi

address=$(echo -e "Internal-Unraid\nExternal-Unraid" | sxmo_dmenu.sh -p "Address")
folders=$(date +"%Y/%m-%Y/")
command="scp ~/'$newfile' $address:/mnt/user/Stuff/Picture\ A\ Day/$folders"
sxmo_terminal.sh -H sh -c "$command"
