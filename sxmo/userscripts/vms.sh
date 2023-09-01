#!/bin/bash
# title="$icon_pwr Unraid VMs"

option=$(echo -e "list\nstart\nshutdown\ndestroy\nreboot" | sxmo_dmenu_with_kb.sh -p "VMs")
address=$(echo -e "Internal-Unraid\nExternal-Unraid" | sxmo_dmenu.sh -p "Address")

if [ "$option" = "List"  ]; then
  sxmo_terminal.sh -H sh -c "ssh $address \"virsh list\""
fi

vm=$(echo -e "Arch\nWindows 11 (Gaming)" | sxmo_dmenu_with_kb.sh -p "VMs")

sxmo_terminal.sh -H sh -c "ssh $address \"virsh $option $vm\""
