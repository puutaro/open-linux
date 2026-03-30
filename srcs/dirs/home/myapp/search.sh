#!/bin/bash

before_con=$(\
	echo -n "$(xclip -selection c -o)")
sleep 0.1
active_win_title=$(\
	xdotool getactivewindow getwindowname\
	| grep -E "erminal$" \
)
case "${active_win_title}" in
	"") xdotool key ctrl+c &
		;;
	*) xdotool key ctrl+shift+c &
		;;
esac || e=$?
wait_pid=$!
sleep 0.2
kill ${wait_pid} || e=$?
en_text=$(\
	xclip -selection c -o \
	| nkf -WwMQ \
	| sed 's/=$//g' \
	| tr = % \
	| tr -d '\n' )
search_url="https://www.google.com/search?q=${en_text}"
brave-browser \
	${search_url} >/dev/null 2>&1 &
echo -n "${before_con}" \
	| xclip  -selection c 
