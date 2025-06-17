#!/bin/bash


set -ue

readonly CURRENT_WINDOW_NAME="$(xdotool getwindowfocus getwindowname)"
case "${CURRENT_WINDOW_NAME}" in
	"xfce4-terminal.Xfce4-terminal")
		xdotool key ctrl+shift+c
		sleep 0.1
		bash "${HOME}/Desktop/share/shell/cmdclick/stock_upsider/aggl.sh" -c
		;;
	*) 
		# xdotool getactivewindow key Ctrl+c
		# sleep 0.2
		# yad --title "$(xclip -selection clipboard -o)"
		# xdotool key ctrl+shift+c
		# sleep 0.1
		bash "${HOME}/Desktop/share/shell/cmdclick/stock_upsider/aggl.sh" -c
esac