#!/bin/bash


set -ue

readonly CURRENT_WINDOW_NAME="$(xdotool getwindowfocus getwindowname)"
case "${CURRENT_WINDOW_NAME}" in
	"xfce4-terminal.Xfce4-terminal")
		xdotool key ctrl+shift+c
		sleep 0.3
		bash "${HOME}/Desktop/share/shell/cmdclick/stock_upsider/aai.sh" -c
		;;
	*) 
		xdotool key ctrl+c
		sleep 0.3
		bash "${HOME}/Desktop/share/shell/cmdclick/stock_upsider/aai.sh" -c
esac