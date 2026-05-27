#!/bin/bash
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
xdotool type "vl"
xdotool key  Return
