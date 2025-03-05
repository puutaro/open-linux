#!/bin/bash
SEARCH_WINDOW="jetbrains-studio.jetbrains-studio"
# "google-chrome.Google-chrome"
ACTIVATE_ACTIVE_WINDOW_ID=$(wmctrl -xl | grep "${SEARCH_WINDOW}" | tail -n -1 | awk '{print $1}')
if [ -n "${ACTIVATE_ACTIVE_WINDOW_ID}" ]; then
	wmctrl -i -a ${ACTIVATE_ACTIVE_WINDOW_ID}
else
	ads &
	wmctrl -i -a $(wmctrl -xl | grep "${SEARCH_WINDOW}" | tail -n -1 | awk '{print $1}')
fi