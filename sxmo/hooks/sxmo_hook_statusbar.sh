#!/bin/sh
# configversion: d557f2116c20cba2d4125e5b274a5a16
# SPDX-License-Identifier: AGPL-3.0-only
# Copyright 2022 Sxmo Contributors

# we disable shellcheck SC2154 (unreferenced variable used)
# shellcheck disable=SC2154

# include common definitions
# shellcheck source=configs/default_hooks/sxmo_hook_icons.sh
. sxmo_hook_icons.sh
# shellcheck source=scripts/core/sxmo_common.sh
. sxmo_common.sh

VPNDEVICE="$(nmcli con show 2>/dev/null | grep -E 'wireguard|vpn' | awk '{ print $1 }')"

set_time() {
	date "+${SXMO_STATUS_DATE_FORMAT:-%H:%M}" | head -c -1 | sxmo_status.sh add 99-time
}

set_state() {
	if grep -q unlock "$SXMO_STATE"; then
		sxmo_status.sh del 4-state
	else
		tr '[:lower:]' '[:upper:]' < "$SXMO_STATE" | sxmo_status.sh add 4-state
	fi
}

set_call_duration() {
	if ! pgrep sxmo_modemcall.sh > /dev/null; then
		sxmo_status.sh del 0-call-duration
		return
	fi

	NOWS="$(date +"%s")"
	CALLSTARTS="$(date +"%s" -d "$(
		grep -aE 'call_start|call_pickup' "$XDG_DATA_HOME"/sxmo/modem/modemlog.tsv |
		tail -n1 |
		cut -f1
	)")"
	CALLSECONDS="$(printf "%s - %s" "$NOWS" "$CALLSTARTS" | bc)"
	printf "%ss " "$CALLSECONDS" | sxmo_status.sh add 5-call-duration
}

_modem() {
	MMCLI="$(mmcli -m any -J 2>/dev/null)"
	MODEMSTATUS=""

	if [ -z "$MMCLI" ]; then
		printf "%s" "$icon_cls"
	else
		MODEMSTATUS="$(printf %s "$MMCLI" | jq -r .modem.generic.state)"
		case "$MODEMSTATUS" in
			locked)
				printf "%s" "$icon_plk"
				;;
			initializing)
				printf "I"
				;;
			disabled) # low power state
				printf "%s" "$icon_mdd"
				;;
			disabling)
				printf ">%s" "$icon_mdd"
				;;
			enabling) # modem enabled but neither registered (cell) nor connected (data)
				printf ">%s" "$icon_ena"
				;;
			enabled)
				printf "%s" "$icon_ena"
				;;
			searching) # i.e. registering
				printf "%s" "$icon_dot"
				;;
			registered|connected|connecting|disconnecting)
				MODEMSIGNAL="$(printf %s "$MMCLI" | jq -r '.modem.generic."signal-quality".value')"
				if [ "$MODEMSIGNAL" -lt 20 ]; then
					printf ""
				elif [ "$MODEMSIGNAL" -lt 40 ]; then
					printf ""
				elif [ "$MODEMSIGNAL" -lt 60 ]; then
					printf ""
				elif [ "$MODEMSIGNAL" -lt 80 ]; then
					printf ""
				else
					printf ""
				fi
				;;
			*)
				# FAILED, UNKNOWN
				# see https://www.freedesktop.org/software/ModemManager/doc/latest/ModemManager/ModemManager-Flags-and-Enumerations.html#MMModemState
				sxmo_log "WARNING: MODEMSTATUS: $MODEMSTATUS"
				printf "<%s>" "$MODEMSTATUS"
				;;
		esac
	fi

	case "$MODEMSTATUS" in
		"connected")
			printf " "
			USEDTECHS="$(printf %s "$MMCLI" | jq -r '.modem.generic."access-technologies"[]')"
			case "$USEDTECHS" in
				*5gnr*)
					printf 5g # no icon yet
					;;
				*lte*)
					printf 4g # ﰒ is in the bad range
					;;
				*umts*|*hsdpa*|*hsupa*|*hspa*|*1xrtt*|*evdo0*|*evdoa*|*evdob*)
					printf 3g # ﰑ is in the bad range
					;;
				*edge*)
					printf E
					;;
				*pots*|*gsm*|*gprs*)
					printf 2g # ﰐ is in the bad range
					;;
				*)
					sxmo_log "WARNING: USEDTECHS: $USEDTECHS"
					printf "<%s>" "$USEDTECHS"
					;;
			esac
			;;
		"connecting")
			printf " >>"
			;;
		"disconnecting")
			printf " <<"
			;;
	esac
}

set_modem() {
	_modem | sxmo_status.sh add 10-modem-status
}

set_modem_monitor() {
	if sxmo_daemons.sh running modem_monitor -q; then
		sxmo_status.sh add 20-modem-monitor-status "$icon_mod"
	else
		sxmo_status.sh del 20-modem-monitor-status
	fi
}

set_wifi() {
	WLANSTATE="$(tr -d "\n" < /sys/class/net/wlan0/operstate)"
	if [ "$WLANSTATE" = "up" ]; then
		sxmo_status.sh add 30-wifi-status "$icon_wif"
	else
		sxmo_status.sh del 30-wifi-status
	fi
}

set_vpn() {
	VPNSTATE="$(nmcli device status | grep -E 'wireguard|vpn' | awk '{ print $3 }')"
	if [ "$VPNDEVICE" != "--" ] && [ "$VPNSTATE" = "connected" ]; then
		sxmo_status.sh add 30-vpn-status "$icon_key"
	else
		sxmo_status.sh del 30-vpn-status
	fi
}

_battery() {
	count=0 # if multiple batteries, add space between them
	for power_supply in /sys/class/power_supply/*; do
		if [ "$(cat "$power_supply"/type)" = "Battery" ]; then
			if [ -e "$power_supply"/capacity ]; then
				PCT="$(cat "$power_supply"/capacity)"
			elif [ -e "$power_supply"/charge_now ]; then
				CHARGE_NOW="$(cat "$power_supply"/charge_now)"
				CHARGE_FULL="$(cat "$power_supply"/charge_full_design)"
				PCT="$(printf "scale=2; %s / %s * 100\n" "$CHARGE_NOW" "$CHARGE_FULL" | bc | cut -d'.' -f1)"
			else
				continue
			fi

			if [ "$count" -gt 0 ]; then
				printf " "
			fi
			count=$((count+1))

			if [ -e "$power_supply"/status ]; then
				# The status is not always given for the battery device.
				# (sometimes it's linked to the charger device).
				BATSTATUS="$(cut -c1 "$power_supply"/status)"
			fi

			# Treat 'Full' status as same as 'Charging'
			if [ "$BATSTATUS" = "C" ] || [ "$BATSTATUS" = "F" ]; then
				if [ "$PCT" -lt 20 ]; then
					printf ""
				elif [ "$PCT" -lt 30 ]; then
					printf ""
				elif [ "$PCT" -lt 40 ]; then
					printf ""
				elif [ "$PCT" -lt 60 ]; then
					printf ""
				elif [ "$PCT" -lt 80 ]; then
					printf ""
				elif [ "$PCT" -lt 90 ]; then
					printf ""
				else
					printf ""
				fi
			else
				if [ "$PCT" -lt 10 ]; then
					printf ""
				elif [ "$PCT" -lt 20 ]; then
					printf ""
				elif [ "$PCT" -lt 30 ]; then
					printf ""
				elif [ "$PCT" -lt 40 ]; then
					printf ""
				elif [ "$PCT" -lt 50 ]; then
					printf ""
				elif [ "$PCT" -lt 60 ]; then
					printf ""
				elif [ "$PCT" -lt 70 ]; then
					printf ""
				elif [ "$PCT" -lt 80 ]; then
					printf ""
				elif [ "$PCT" -lt 90 ]; then
					printf ""
				else
					printf ""
				fi
			fi

			[ -z "$SXMO_BAR_HIDE_BAT_PER" ] && printf " %s%%" "$PCT"
		fi
	done
}

set_battery() {
	 _battery | sxmo_status.sh add 40-battery-status
}

_volume() {
	case "$(sxmo_audio.sh device get 2>/dev/null)" in
		Speaker|"")
			# nothing for default or pulse devices
			;;
		Headphones)
			printf "%s " "$icon_hdp"
			;;
		Earpiece)
			printf "%s " "$icon_ear"
			;;
	esac

	VOL="$(sxmo_audio.sh vol get)"
	if [ -z "$VOL" ] || [ "$VOL" -eq 0 ]; then
		printf "%s" "$icon_mut"
	elif [ "$VOL" -gt 66 ]; then
		printf "%s" "$icon_spk"
	elif [ "$VOL" -gt 33 ]; then
		printf "%s" "$icon_spm"
	elif [ "$VOL" -gt 0 ]; then
		printf "%s" "$icon_spl"
	fi
}

set_volume() {
	 _volume | sxmo_status.sh add 50-volume
}

set_temp() {
	echo "$(cat /sys/class/thermal/thermal_zone0/temp | cut -c 1,2)°C" | sxmo_status.sh add 3-temp
}

set_mem() {
	vmstat -S M -s | awk '{print $1,$2}' | head -n 2 | tac | tr -d '\n' | sed 's/ M/M\//g' | rev | cut -c2- | rev | sxmo_status.sh add 2-mem
}

set_cpu() {
	top -bn2 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}' | sed -n '2p' | sxmo_status.sh add 1-cpu
}

case "$1" in
	network_wlan0)
		set_wifi
		;;
	network_$VPNDEVICE)
		set_vpn
		;;
	time|call_duration|modem|modem_monitor|battery|volume|state|mem|temp|cpu)
		set_"$1"
		;;
	periodics|state_change) # 55 s loop and screenlock triggers
		set_time
		set_modem
		set_battery
		set_state
		set_cpu
		set_mem
		set_temp
		;;
	all)
		sxmo_status.sh reset
		set_time
		set_call_duration
		set_modem
		set_modem_monitor
		set_wifi
		set_vpn
		set_battery
		set_volume
		set_state
		set_cpu
		set_mem
		set_temp
		;;
	*)
		exit
		;;
esac
