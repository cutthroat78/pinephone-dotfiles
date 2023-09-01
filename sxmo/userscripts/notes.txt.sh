#!/bin/bash
# title="$icon_edt Notes.txt"

option=$(echo -e "dmenu\nvim" | sxmo_dmenu.sh -p "dmenu or vim?")

if [ $option = "dmenu" ];
then
	echo "- $(sxmo_dmenu_with_kb.sh -p "Note:")" >> /home/alarm/notes.txt
fi

if [ $option = "vim" ];
then
	sxmo_terminal.sh sh -c "vim /home/alarm/notes.txt"
fi
