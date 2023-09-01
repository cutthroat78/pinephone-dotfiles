#!/bin/bash
# title="$icon_cpy Move Notes"

address=$(echo -e "Internal-Unraid\nExternal-Unraid" | sxmo_dmenu.sh -p "SSH Address")
option=$(echo -e "Yes\nNo" | sxmo_dmenu.sh -p "Delete Local Notes")

sxmo_terminal.sh -H sh -c "scp -r ~/{notes.txt,notes/*} $address:/mnt/user/Stuff/Workspace/notes/"

if [ $option = "Yes" ]
then
  rm -rf ~/notes/*
fi
