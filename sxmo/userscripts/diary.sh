#!/bin/bash
# title="$icon_bok Diary"

date=$(echo -e "today\nyesterday\n01 01 1970" | sxmo_dmenu_with_kb.sh -p "Diary Entry Date")
address=$(echo -e "Internal-Unraid\nExternal-Unraid" | sxmo_dmenu.sh -p "Address")

command="ssh $address \"cd /mnt/user/Stuff/Workspace/Diary && ./Diary.sh $date\""
sxmo_terminal.sh sh -c "$command"
