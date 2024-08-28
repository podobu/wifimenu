#!/bin/bash

if [ $1 ]; then
	echo -en "\
Usage: $(basename $0) [argument]

    Displays a wofi menu to select a Wi-Fi network.
    If at least one argument is given, it displays this help.

    Nerd Fonts icons are used. A font can be downloaded at:
    https://www.nerdfonts.com/
    
	Dependencies: networkManager, wofi.
"
	exit
fi

ask-password () {
	show_message=${1:-"Show password"}
	hide_message=${2:-"Hide password"}
	middle_message=${3:-}
	cancel_message=${4:-"Cancel"}
	last_mesagge=${5:-}
	wifi_password=""
	until [[ "$wifi_password" =~ ^[^󰛑󰛐] && -n $wifi_password ]]; do
		if [[ "$wifi_password" =~ ^󰛑 ]]; then
			wifi_password=$(echo -e "󰛐  ${show_message}${middle_message}\n  ${cancel_message}$last_mesagge" | wofi --dmenu --password --prompt "Password:")
		else
			wifi_password=$(echo -e "󰛑  ${hide_message}${middle_message}\n  ${cancel_message}$last_mesagge" | wofi --dmenu --prompt "Password:")
		fi
	done
	echo "$wifi_password"
}

get-prelist () {
	connection_state=$(nmcli --colors no --get-values WIFI general)
	disable_message="󰖪  Disable Wi-Fi"
	enable_message="󰖩  Enable Wi-Fi"
	hidden_message="󰛐  Connect to a hidden network"
	forget_message="  Forget Connection"

	if [ "$connection_state" = "enabled" ]; then
		echo -e "$disable_message\n$hidden_message\n$forget_message\n"
	elif [ "$connection_state" = "disabled" ]; then
		echo -e "$enable_message\n$forget_message"
	fi
}

connect-hidden () {
	wifi_hidden=$(echo | wofi --dmenu --prompt "Network name")

	if [ -z $wifi_hidden ]; then
		exit
	fi

	wifi_password=$(ask-password "" "" "\n  Without password")

	if [[ "$wifi_password" =~ ^ ]]; then
		wifi_password=""
	elif [[ "$wifi_password" =~ ^ ]]; then
		exit
	fi

	nmcli device wifi connect "$wifi_hidden" hidden yes password "$wifi_password"
}

forget-connection () {
	chosen=$(echo "$(nmcli --colors no --get-values TYPE,NAME connection show)" | awk -F ':' '$1 == "802-11-wireless" {print "󰑩  " $2}' | wofi --dmenu --insensitive --prompt "Conexión a olvidar:")

	if [ -z "$chosen" ]; then
		exit
	fi

	chosen=${chosen:3}
	sure=$(echo -e "  Yes\n  No" | wofi --dmenu --insensitive --prompt "¿Forget ${chosen}?")

	if [[ "$sure" =~ ^ ]]; then
		nmcli connection delete id $chosen
	fi
}

connect-wifi () {
	wifi_security=${1:0:1}
	wifi_ssid=${1:3}

	if [ $(echo "$(nmcli --colors no --get-values NAME connection show)" | grep --word-regexp "$wifi_ssid") ]; then
		nmcli connection up id "$wifi_ssid"
	else
		if [[ "$wifi_security" =~ ^[󰤪󰤤󰤡] ]]; then
			wifi_password=$(ask-password)
			if [[ "$wifi_password" =~ ^ ]]; then
				exit
			fi
		fi 
		nmcli device wifi connect "$wifi_ssid" password "$wifi_password"
    fi
}

wifi_list=$(nmcli --colors no --get-values SECURITY,SIGNAL,SSID,IN-USE device wifi list --rescan auto | awk -F ':' '
$3 {
if ($1 ~ /^WPA/)
	if ($2 > 80)
		sub($1, "󰤪")
	else if ($2 > 60)
		sub($1, "󰤤")
	else
		sub($1, "󰤡")
else if ($1 == "")
	if ($2 > 80)
		sub($1, "󰤨")
	else if ($2 > 60)
		sub($1, "󰤢")
	else
		sub($1, "󰤟")
if ($4 == "*")
	sub($1, "")
print $1 "  " $3
}
')

chosen=$(echo -e "$(get-prelist)${wifi_list:+\n}$wifi_list" | wofi --dmenu --insensitive --prompt "Wi-Fi SSID:")

if [ "$chosen" = "" ]; then
	exit
elif [[ "$chosen" =~ ^󰖩 ]]; then
	nmcli radio wifi on
elif [[ "$chosen" =~ ^󰖪 ]]; then
	nmcli radio wifi off
elif [[ "$chosen" =~ ^󰛐 ]]; then
	connect-hidden
elif [[ "$chosen" =~ ^ ]]; then
	forget-connection
elif [[ "$chosen" =~ ^ ]]; then
	nmcli connection down id "${chosen:3}"
else
	connect-wifi "$chosen"
fi
