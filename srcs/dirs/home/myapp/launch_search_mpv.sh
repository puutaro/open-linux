#!/bin/bash

e=""
focus_termial(){
	local SEARCH_WINDOW="xfce4-terminal.Xfce4-terminal"

	local ACTIVATE_ACTIVE_WINDOW_ID=$(wmctrl -xl | grep "${SEARCH_WINDOW}" | tail -n -1 | awk '{print $1}')
	case "${ACTIVATE_ACTIVE_WINDOW_ID}" in 
		"") 
			xfce4-terminal --title "${SEARCH_WINDOW}" --maximize &
			;;
		*) 
			wmctrl -i -a ${ACTIVATE_ACTIVE_WINDOW_ID} 
			;; esac
}

focus_termial
sleep 0.2
readonly romaji_on=2
if [ "$(fcitx5-remote)" -eq "${romaji_on}" ];then
	xdotool key Zenkaku_Hankaku || e=$?
fi
sleep 0.1
xdotool key "v"
xdotool key  Return
