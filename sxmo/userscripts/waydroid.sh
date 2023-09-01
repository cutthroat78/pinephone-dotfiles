#!/bin/bash
# title="$icon_and Waydroid"

option=$(echo -e "Open Full UI\nOpen App\nSession Start\nSession Stop\nStart Container\nStop Container" | sxmo_dmenu.sh -p "Waydroid Options")

if [ "$option" = "Open Full UI" ]
then
  waydroid show-full-ui
fi

if [ "$option" = "Open App" ]
then
  waydroid app launch $(waydroid app list | grep packageName | cut -c 14- | sxmo_dmenu.sh -p "Android Apps")
fi

if [ "$option" = "Start Container" ]
then
  sudo systemctl start waydroid-container
fi

if [ "$option" = "Stop Container" ]
then
  sudo systemctl stop waydroid-container
fi

if [ "$option" = "Session Start" ]
then
  waydroid session start
fi

if [ "$option" = "Session Stop" ]
then
  waydroid session stop
fi
