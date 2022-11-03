#!/bin/bash

LANG=ja_JP.utf8

SEARCH_WINDOW="nemo.Nemo"
TARGET_TAB_NAME="\.Recent"
TARGET_TAB_NAME_JA="最近"
start_path="recent:///"
nemo_only_active="${1}"

search_target_tab(){
	local roop=1
	local search_times=10
	while true
	do
		local get_cur_tab_title=$(wmctrl -lx | rga "${SEARCH_WINDOW}" | tail -n -1 | awk -F" " '{for(i=4;i<NF;i++) {printf("%s%s",$i,OFS=".")} print $NF}')
		case "${get_cur_tab_title}" in  "${get_first_tab_title}") 
			[ ${roop} -gt ${search_times} ] && break ;; esac
		local get_target_tab=$(echo "${get_cur_tab_title}" | rga -e "${TARGET_TAB_NAME}" -e "${TARGET_TAB_NAME_JA}" | tail -n -1 | awk '{print $1}')
		case "${get_target_tab}" in "");; *) exit 0;; esac
		case "${roop}" in 
			"1") get_first_tab_title="${get_cur_tab_title}" ;; esac
		roop=$((${roop} + 1))
		case "${roop}" in "${search_times}") break;; esac
		xdotool key Ctrl+Tab
		wait
	done
}

ACTIVATE_ACTIVE_WINDOW_ID=$(wmctrl -xl | grep "${SEARCH_WINDOW}" | tail -n -1 | awk '{print $1}')
case "${ACTIVATE_ACTIVE_WINDOW_ID}" in 
	"") 
		nemo "${start_path}" &
		exit 0
		;;
	*) 
		wmctrl -i -a ${ACTIVATE_ACTIVE_WINDOW_ID} 
		case "${nemo_only_active}" in "");;
			*) exit 0 ;; esac
		search_target_tab
		echo -n ''${start_path}'' | xclip -selection c
		xdotool key Ctrl+t && sleep 0.1 && xdotool key Ctrl+l && sleep 0.05 && xdotool key Ctrl+v && sleep 0.05 && xdotool key Return
		exit 0
		;; esac