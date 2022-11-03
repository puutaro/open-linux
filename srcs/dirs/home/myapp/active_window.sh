#!/bin/bash

SEARCH_WINDOW="active_window_$USER"
ACTIVATE_ACTIVE_WINDOW_ID=$(wmctrl -xl | grep "${SEARCH_WINDOW}" | head -n 1 | tail -n -1 | awk '{print $1}')
if [ -n "${ACTIVATE_ACTIVE_WINDOW_ID}" ]; then
	wmctrl -i -a ${ACTIVATE_ACTIVE_WINDOW_ID}
else
	xdotool windowactivate $WINDOWID
	echo "please type active window name"
	read -e WINDOW_TITLE
	ACTIVE_WINDOW_ID=$(wmctrl -lx | grep -i "${WINDOW_TITLE}" | head -n 1 | tail -n -1 | awk '{print $1}')
	if [ -n "${ACTIVE_WINDOW_ID}" ]; then
		wmctrl -i -a ${ACTIVE_WINDOW_ID}
	fi
fi