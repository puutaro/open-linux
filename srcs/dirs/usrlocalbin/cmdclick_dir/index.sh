#!/bin/bash

LANG=C
# lecho "BEFORE INDEX INDEX_CODE: ${INDEX_CODE}"
LOOP=0
#すでにアクティブがある場合、そちらを開く
case "${ACTIVE_CHECK_VARIABLE}" in 
	"0")
		ACTIVE_CHECK_VARIABLE=1
		acctive_check=$(wmctrl -l | grep -i "${WINDOW_TITLE}")
		case "${acctive_check}" in 
			"");; 
			*) wmctrl -a "${WINDOW_TITLE}"; exit 0;;
		esac
	;;
esac

get_inc_dir_file(){
	#echo "CMDCLICK_APP_LIST_PATH: ${CMDCLICK_CONF_DIR_PATH}" >> "${CMDCLICK_APP_LIST_PATH}"
	local sed_cmdclick_conf_dir_path=$(echo "${CMDCLICK_CONF_DIR_PATH}" | sed 's/\//\\\//g')
	#echo "sed_cmdclick_conf_dir_path: ${sed_cmdclick_conf_dir_path}" >> "${CMDCLICK_APP_LIST_PATH}"
	local change_dir_path_list=($(ls -ultF "${CMDCLICK_CONF_DIR_PATH}" | rga "${COMMAND_CLICK_EXTENSION}" | awk '{print $9}' | sed  -e 's/^/'${sed_cmdclick_conf_dir_path}'\//g' -e '/^$/d'))
	local change_dir_path=$(cat ${change_dir_path_list[@]} | rga "^${CH_DIR_PATH}=" | sed  -e 's/^'${CH_DIR_PATH}'\=//' -e '/^$/d')
	eval "echo \"${change_dir_path}\""  > "${CMDCLICK_APP_LIST_PATH}"
	}

get_inc_dir_file

cur_inc=$(cat "${CMDCLICK_CONF_INC_CMD_PATH}" 2>/dev/null | rga "^${GREP_INC_NUM}=" | sed 's/'${GREP_INC_NUM}'\=//' | sed '/^$/d')
case "${cur_inc}" in 
	"")
		cur_inc=1
		echo "${GREP_INC_NUM}=${cur_inc}" > "${CMDCLICK_CONF_INC_CMD_PATH}" &
		;;
esac 
SECONDS_INI_FILE_DIR_PATH=$(cat "${CMDCLICK_APP_LIST_PATH}" | sed -n ''${cur_inc}'p')
if [ ! -e "${SECONDS_INI_FILE_DIR_PATH}" ];then 
	mkdir -p "${SECONDS_INI_FILE_DIR_PATH}";
	INI_FILE_DIR_PATH="${SECONDS_INI_FILE_DIR_PATH}"; 
else 
	INI_FILE_DIR_PATH="${SECONDS_INI_FILE_DIR_PATH}"; 
fi
# lecho "index:CMDCLICK_CD_FILE_PATH: ${CMDCLICK_CD_FILE_PATH}"
#index立ち上げ
INDEX_TITLE_TEXT_MESSAGE=${INDEX_SELECT_CMD_MESSAGE}
input_cmd_index ${INI_FILE_DIR_PATH}
# lecho "AFTER_INDEX SIGNAL_CODE: ${SIGNAL_CODE}"
