#!/bin/bash

LANG=ja_JP.utf8

SEARCH_WINDOW="xfce4-terminal.Xfce4-terminal"

ACTIVATE_ACTIVE_WINDOW_ID=$(wmctrl -xl | grep "${SEARCH_WINDOW}" | tail -n -1 | awk '{print $1}')
case "${ACTIVATE_ACTIVE_WINDOW_ID}" in 
	"") 
		xfce4-terminal --title "${SEARCH_WINDOW}" --maximize &
		exit 0
		;;
	*) 
		wmctrl -i -a ${ACTIVATE_ACTIVE_WINDOW_ID} 
		;; esac