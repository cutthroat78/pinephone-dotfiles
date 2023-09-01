#!/bin/bash
# title="$icon_phn Check Credit Balance"

sxmo_notify_user.sh "$(mmcli -m any --3gpp-ussd-initiate="*#100#")"
