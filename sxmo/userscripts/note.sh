#!/bin/bash
# title="$icon_edt Note"

filename=$(echo $(sxmo_dmenu_with_kb.sh -p "Filename").md)
option=$(echo -e "dmenu\nvim" | sxmo_dmenu.sh -p "dmenu or vim?")

if [ $option = "dmenu" ];
then
	echo -e "$(sxmo_dmenu_with_kb.sh -p "Note")\n" >> /home/user/notes/$filename
fi

if [ $option = "vim" ];
then
	sxmo_terminal.sh sh -c "vim /home/user/notes/$filename"
fi
