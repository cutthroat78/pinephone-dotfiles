#!/bin/bash
# title="$icon_trm sshd"
option=$(echo -e "Start\nStop" | sxmo_dmenu.sh -p "Start or Stop sshd?")

if [ $option = "Start" ]
then
  sxmo_terminal.sh sh -c "sudo systemctl start sshd"
fi


if [ $option = "Stop" ]
then
  sxmo_terminal.sh sh -c "sudo systemctl stop sshd"
fi
