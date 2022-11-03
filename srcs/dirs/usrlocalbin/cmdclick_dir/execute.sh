#!/bin/bash

LANG=C
LOOP=0
# lecho "BEFORE_EXECUTE SIGNAL_CODE: ${SIGNAL_CODE}"
EXECUTE_FILE_PATH="${INI_FILE_DIR_PATH}/${EXECUTE_FILE_NAME}"
#設定ファイルチェック
check_ini_file "${EXECUTE_FILE_PATH}"
#SIGNAL_CODE=${CHECK_ERR_CODE}
case "${SIGNAL_CODE}" in
	"${OK_CODE}") 
		#設定ファイルからコマンドを製造
		touch "${EXECUTE_FILE_PATH}" &
		EXEC_INPUT_EXECUTE="$(cat "${EXECUTE_FILE_PATH}" | rga "${INI_INPUT_EXECUTE}=" | sed 's/'${INI_INPUT_EXECUTE}'\=//')"
		case "${EXEC_INPUT_EXECUTE}" in 
			"C")
				cat "${EXECUTE_FILE_PATH}" | rga "${INI_IN_EXE_DFLT_VL}="
				echo --
				EXEC_IN_EXE_DFLT_VL="$(cat "${EXECUTE_FILE_PATH}" | rga "${INI_IN_EXE_DFLT_VL}=" | sed  -e 's/'${INI_INPUT_EXECUTE}'\=//'  | sed  -re "s/([a-zA-Z0-9_-]{1,100})=(.*)/\2/" | sed -e 's/"$//' -e 's/^"//' | tr ',' '\n'  | sed -e 's/\\$//' -e 's/^\s*//' | sed  -r "s/(^[a-zA-Z0-9_-]{0,100})(\:CB)=(.*)/ \| sed 's\/^\1=.*\/\1\2=\3\/'/" | sed  -r "s/(^[a-zA-Z0-9_-]{0,100})=(.*)/ \| sed 's\/^\1=.*\/\1=\2\/'/"  | tr -d '\n' | sed '/^$/d'  | sed 's/ | sed /\n | sed /g' | rga "[' ]$" | tr -d '\n')"
				echo EXEC_IN_EXE_DFLT_VL
				echo "${EXEC_IN_EXE_DFLT_VL}"
				# echo EXEC_IN_EXE_DFLT_VL_sed
				# echo "${EXEC_IN_EXE_DFLT_VL}" | sed 's/ | sed /\n | sed /g'
				# echo EXEC_IN_EXE_DFLT_VL_sed_rga
				# echo "${EXEC_IN_EXE_DFLT_VL}" | sed 's/ | sed /\n | sed /g' | rga "[' ]$" | tr -d '\n'
				# echo "${EXEC_IN_EXE_DFLT_VL}"
				
				edit_ini_gui "${EXECUTE_FILE_NAME}";wait 
				check_ini_file "${EXECUTE_FILE_PATH}"
				;;
			"E")
				EDIT_EDITOR_ON="ON"
				EDIT_FILE_PATH
				edit_ini_gui "${EXECUTE_FILE_NAME}"; wait 
				check_ini_file "${EXECUTE_FILE_PATH}"
				echo SIGNAL_CODE ${SIGNAL_CODE}
				# EXEC_INPUT_EXECUTE_SIGNAL 
				# ref:cmdclick_dir/lib/edit_lib/edit_function.sh
				SIGNAL_CODE=${EXEC_INPUT_EXECUTE_SIGNAL}
				;;
		esac
		case "${SIGNAL_CODE}" in
			"${OK_CODE}")
				read_ini_to_execute_command "${EXECUTE_FILE_PATH}" ;;
		esac 
	;;
esac
# echo "BEFORE_EXECUTE setting_variable "
# echo "EXECUTE_COMMAND: ${EXECUTE_COMMAND}"
# echo "EXEC_TERMINAL_ON: ${EXEC_TERMINAL_ON}"
# echo "EXEC_OPEN_WHERE: ${EXEC_OPEN_WHERE}"
# echo "EXEC_TERMINAL_SIZE: ${EXEC_TERMINAL_SIZE}"
# echo "EXEC_TERMINAL_FOCUS: ${EXEC_TERMINAL_FOCUS}"
# echo "EXEC_INPUT_EXECUTE: ${EXEC_INPUT_EXECUTE}"
# echo "EXEC_IN_EXE_DFLT_VL: ${EXEC_IN_EXE_DFLT_VL}"
# echo "EXEC_BEFORE_COMMAND: ${EXEC_BEFORE_COMMAND}"
# echo "EXEC_AFTER_COMMAND: ${EXEC_AFTER_COMMAND}"
# echo "EXECUTE_FILE_PATH: ${EXECUTE_FILE_PATH}"
#ターミナル起動コマンド格納
if [ "${EXEC_TERMINAL_ON}" = "ON" ]; then
	terminal_exec_command="x-terminal-emulator -T \"${CC_TERMINAL_NAME}\" &"
else 
	terminal_exec_command=""
fi

#ターミナルリサイズコマンド格納
case "${EXEC_TERMINAL_SIZE}" in 
	"MAX")
		exec_terminal_size_command="xdotool key super+Up; xdotool key super+Up"
		;;
	"RMAX")
		exec_terminal_size_command="xdotool key super+Right"
		;;
	"LMAX")
		exec_terminal_size_command="xdotool key super+Left"
		;;
esac
# lecho "BEFORE_EXECUTE exec_terminal_size_command: ${exec_terminal_size_command} "
#ターミナル使用時（デフォルト）
case "${EXEC_TERMINAL_ON}" in 
	"ON")
		#コマンド実行前の準備-------------------------------------
		#terminalを開く前の準備（サイズ、タブ、アクティブ化）
		case "${EXEC_OPEN_WHERE}" in 
			"NW")
				# ccerminal_acctive_state=$(wmctrl -lx | grep -i "$2" | grep -i terminal | tail -n -1 | awk '{print $1}')
				ccerminal_acctive_state=$(wmctrl -lx | rga "${CC_TERMINAL_NAME}" | tail -n -1 | awk '{print $1}')
				case "${ccerminal_acctive_state}" in 
					"") ;;
					*) wmctrl -i -a "${ccerminal_acctive_state}" | wmctrl -r :ACTIVE: -N "Terminal"
					;;
				esac
				wait
				bash -c "${terminal_exec_command}"
				sleep 0.5
				wait
				;;
		esac
		#実行可能なCCerminalを取得、なければ、ターミナルで代用
		ccerminal_window_list=$(wmctrl -lx | grep -i "${CC_TERMINAL_NAME}" | grep -i "terminal" | tail -n -1 | awk '{print $1}')
		case "${ccerminal_window_list}" in 
			"")
				ccerminal_window_list=$(wmctrl -lx | grep -i terminal | tail -n -1 | awk '{print $1}')
				case "${ccerminal_window_list}" in 
					"")
						bash -c "${terminal_exec_command}"
						ccerminal_window_list=$(wmctrl -lx | grep -i terminal | tail -n -1 | awk '{print $1}')
						wait
						sleep 0.5
					;;
				esac
			;;
		esac
		current_term_active_cmd="wmctrl -i -a ${ccerminal_window_list}"
		# echo "BEFORE_EXECUTE ccerminal_window_list: ${ccerminal_window_list}"
		bash -c "${current_term_active_cmd}; ${exec_terminal_size_command}"
		# echo "bash -c ${current_term_active_cmd}; ${exec_terminal_size_command}"

		#新しいタブで開く場合	
		case "${EXEC_OPEN_WHERE}" in 
			"NT")
				open_where_ntab_command="xdotool key ctrl+shift+t"
				bash -c "${open_where_ntab_command}"
				wait
			;;
		esac
		#-----------------------------------------------------------------

		#以後、コマンド系----------------------------------------------------
		# #ディレクトリ移動
		# if [ -d "${EXEC_WORKING_DIRECTORY}" ]; then
		# 	echo "BEFORE_EXECUTE EXEC_WORKING_DIRECTORY: ${EXEC_WORKING_DIRECTORY}"
		# 	cd_work_dir="cd ${EXEC_WORKING_DIRECTORY}"
		# 	current_dir_path=$(pwd)
		# 	execute_cmd_by_xdotool "${cd_work_dir}" "${ccerminal_window_list}"
		# 	wait
		# fi
		#事前コマンド
		if [ "${EXEC_BEFORE_COMMAND}" == "-" ] || [ -z "${EXEC_BEFORE_COMMAND}" ]; then
			:
		else
			#sh -c "xdotool type '${EXEC_BEFORE_COMMAND}';  xdotool key Return"
			# echo "BEFORE_EXECUTE EXEC_BEFORE_COMMAND: ${EXEC_BEFORE_COMMAND}"
			execute_cmd_by_xdotool "${EXEC_BEFORE_COMMAND}" "${ccerminal_window_list}" 
		fi
		#実行コマンド（本体）
		execute_cmd_by_xdotool "${EXECUTE_COMMAND}" "${ccerminal_window_list}"
		#xdotool type "eval \"${EXECUTE_COMMAND}\""; xdotool key Return; wmctrl -i -a ${ccerminal_window_list}
		#実行後コマンド
		if [ "${EXEC_AFTER_COMMAND}" == "-" ] || [ -z "${EXEC_AFTER_COMMAND}" ]; then
			:
		else
			# echo "AFTER_EXECUTE EXEC_AFTER_COMMAND: ${EXEC_AFTER_COMMAND}"
			execute_cmd_by_xdotool "${EXEC_AFTER_COMMAND}" "${ccerminal_window_list}"
		fi
		;;
	"OFF")
		bash -c "${EXECUTE_COMMAND} &"
		;;
esac
SIGNAL_CODE=${INDEX_CODE}
# echo "AFTER_EXECUTE SIGNAL_CODE: ${SIGNAL_CODE}"		