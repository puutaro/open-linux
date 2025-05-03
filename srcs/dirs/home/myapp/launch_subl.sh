#!/bin/bash
SEARCH_WINDOW="sublime_text.Sublime_text"
ACTIVATE_ACTIVE_WINDOW_ID=$(wmctrl -xl | grep "${SEARCH_WINDOW}" | tail -n -1 | awk '{print $1}')
if [ -n "${ACTIVATE_ACTIVE_WINDOW_ID}" ]; then
	wmctrl -i -a ${ACTIVATE_ACTIVE_WINDOW_ID}
else
	subl &
	wmctrl -i -a $(wmctrl -xl | grep "${SEARCH_WINDOW}" | tail -n -1 | awk '{print $1}')
fi
