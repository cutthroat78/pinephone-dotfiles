#!/bin/bash
# title="$icon_mus spotifyd"

option=$(echo -e "Start\nStop" | sxmo_dmenu.sh -p "Spotifyd")

if [ "$option" = "Start" ]; then
  spotifyd -u "(add username here)" -p '(add pass here)' -d "Pine"
fi

if [ "$option" = "Stop" ]; then
  pkill spotifyd
fi
