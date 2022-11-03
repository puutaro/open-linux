#!/bin/bash

reload_cmd(){
	LANG=C
	local inc_num=$(cat "${CMDCLICK_CONF_INC_CMD_PATH}" | rga "^${GREP_INC_NUM}=" | sed -e 's/'${GREP_INC_NUM}'\=//' -e '/^$/d')
	SECONDS_INI_FILE_DIR_PATH=$(cat "${CMDCLICK_APP_LIST_PATH}"  | sed -n ''${inc_num}'p')
	if [ ! -e "${SECONDS_INI_FILE_DIR_PATH}" ];then mkdir -p "${SECONDS_INI_FILE_DIR_PATH}";fi
	local sed_home_path=$(echo "${HOME}" | sed 's/\//\\\//g')
	local display_sec_ini_path=$(echo "${SECONDS_INI_FILE_DIR_PATH}" | sed 's/'${sed_home_path}'/~/')
	local sed_dir_path=$(echo "${SECONDS_INI_FILE_DIR_PATH}" | sed 's/\//\\\//g')

	case "${SIGNAL_CODE}" in 
		"${DELETE_CODE}"|"${EDIT_CODE}")
				local ini_file_list=$(ls -ultF  "${SECONDS_INI_FILE_DIR_PATH}/" | sed 's/\*$//g' | rga ''${COMMAND_CLICK_EXTENSION}'' | awk '{print $9}' | sed -e '1i ['${display_sec_ini_path}']' -e 's/$/\t'${sed_dir_path}'/' | rga -v "${CMDCLICK_EDIT_CMD}" | rga -v "${CMDCLICK_DELETE_CMD}" | rga -v "${CMDCLICK_CHANGE_DIR_CMD}" | grep -v "${CMDCLICK_RESOLUTION_CMD}" | rga -v "${CMDCLICK_ADD_CMD}")
				case "${ini_file_list}" in
					"") 
						local ini_file_list="$(cat <(echo "[${display_sec_ini_path}"]) <(echo "-") | sed 's/$/\t'${sed_dir_path}'/')"
						;;
				esac
				;;
		*)
			local ini_file_list=$(ls -ultF  "${SECONDS_INI_FILE_DIR_PATH}/" | sed 's/\*$//g' | rga ''${COMMAND_CLICK_EXTENSION}'' | awk '{print $9}' | sed -e 's/$/\t'${sed_dir_path}'/' -e '1i ['${display_sec_ini_path}']' -e 's/$/\t'${sed_dir_path}'/')
			case "${ini_file_list}" in
				"")
					local ini_file_list="$(cat <(echo "[${display_sec_ini_path}"]) <(echo "-") | sed 's/$/\t'${sed_dir_path}'/')"
					;;
			esac
			echo "${ini_file_list}"
	esac
	touch "${SECONDS_INI_FILE_DIR_PATH}"
}

exec_inc(){
	LANG=C
	local inc_con=$(cat "${CMDCLICK_CONF_INC_CMD_PATH}")
	local inc_sup=$(cat "${CMDCLICK_APP_LIST_PATH}" | wc -l | sed 's/\ //g')
	local inc_num=$(echo "${inc_con}" | rga "^${GREP_INC_NUM}=" | sed -e 's/'${GREP_INC_NUM}'\=//' -e '/^$/d')
	if [ ${inc_num} -ge ${inc_sup} ];then local inc_num_after=1;
	else local inc_num_after=$((${inc_num} + 1));fi
	echo "${GREP_INC_NUM}=${inc_num_after}" > "${CMDCLICK_CONF_INC_CMD_PATH}"
}

exec_dec(){
	LANG=C
	local inc_con=$(cat "${CMDCLICK_CONF_INC_CMD_PATH}")
	local inc_sup=$(cat "${CMDCLICK_APP_LIST_PATH}" | wc -l | sed 's/\ //g')
	local inc_num=$(echo "${inc_con}" | rga "^${GREP_INC_NUM}=" | sed -e 's/'${GREP_INC_NUM}'\=//' -e '/^$/d')
	if [ ${inc_num} -le 1 ];then local inc_num_after=${inc_sup};
	else local inc_num_after=$((${inc_num} - 1));fi
	echo "${GREP_INC_NUM}=${inc_num_after}" > "${CMDCLICK_CONF_INC_CMD_PATH}"
}

input_cmd_index(){
	if [ ! -e ${CMDCLICK_DEFAULT_CD_FILE_PATH} ];then add_chdir_cmd_ini_file "${CMDCLICK_DEFAULT_INI_FILE_DIR_PATH}" "${CMDCLICK_DEFAULT_INI_FILE_DIR_PATH}"; fi
	set +ux
	#画面大きさ策定
	#まず、解像度取得
	local display_rsolution_list=($(xrandr | grep '*' | awk '{print $1}' | sed -e 's|x| |g'))
	#パネルサイズ取得
	WIN_DEPTH=30
	xwin_info=$(xwininfo -name panel)
	local IFS=$'\n' 
	local panal_size=($(echo "${xwin_info}" | rga -e "Width" -e "Height" |  sed "s|[^0-9]||g"))
	local IFS=$' \n\t' 
	#パネルの位置（左、上、下）にあわせて、現在の縦横サイズ計算
	if [ ${panal_size[0]} -ge ${panal_size[1]} ]; then
		local true_display_resolution[0]=$(expr ${display_rsolution_list[0]})
		local true_display_resolution[1]=$(expr ${display_rsolution_list[1]} - ${panal_size[1]})
	else
		local true_display_resolution[0]=$(expr ${display_rsolution_list[0]} - ${panal_size[0]})
		local true_display_resolution[1]=$(expr ${display_rsolution_list[1]})
	fi
	scale_display_width=$(echo "scale=0; ${true_display_resolution[0]} / 3.0" | bc)
	scale_display_height=$(expr ${true_display_resolution[1]})
	#パネルの座標を取得
	local IFS=$'\n' 
	local panel_absolute_upper_left=($(echo "${xwin_info}" | rga -e 'Absolute upper-left X' -e 'Absolute upper-left Y' | sed "s|[^0-9]||g"))
	local IFS=$' \n\t' 
	#パネルが左、上、下いずれかを判断
	if [ ${panal_size[0]} -ge ${panal_size[1]} ] && [ ${panel_absolute_upper_left[1]} -eq 0 ]; then
		# lecho "offset_start top"
		local panel_position="t"
	elif [ ${panal_size[0]} -le ${panal_size[1]} ] && [ ${panel_absolute_upper_left[0]} -eq 0 ] && [ ${panel_absolute_upper_left[1]} -eq 0 ]; then
		# lecho "offset_start left"
		local panel_position="l"
	elif [ ${panal_size[0]} -ge ${panal_size[1]} ] && [ ${panel_absolute_upper_left[0]} -ge 0 ]  && [ ${panel_absolute_upper_left[1]} -ge  100 ]; then
		# lecho "offset_start bottom"
		local panel_position="b"
	fi
	#index画面のウィンドウサイズと座標を決定
	# lecho "panal_size: ${panal_size[@]}"
	GEOMETRY=""
	WINDOW_MINIMAL_WIDTH=578
	case "${EXECUTE_COMMAND}" in 
		"")
			local scale_display_width=$(echo "scale=0; ${display_rsolution_list[0]} / 1.9" | bc)
			local scale_display_height=$(echo "scale=0; ${display_rsolution_list[1]} / 1.1" |bc)
			local x_posithon=$(( (${true_display_resolution[0]} - ${scale_display_width}) / 2 ))
			local y_posithon=$(( (${true_display_resolution[1]} - ${scale_display_height})))
			;;
		*)
			if [ "${EXEC_TERMINAL_ON}" = "ON" ] || [ "${EXEC_TERMINAL_ON}" = "OFF" ]; then
				case "${EXEC_TERMINAL_SIZE}" in
					"RMAX") 
						x_posithon=0
						y_posithon=0
						if [ ${panel_position} = "l" ]; then
							x_posithon=$(expr ${x_posithon} + ${panal_size[0]})
						elif [ ${panel_position} = "t" ]; then
							y_posithon=$(expr ${y_posithon} + ${panal_size[1]})
						fi
						# lecho "{scale_display_width} {scale_display_height}"
						# lecho "{$scale_display_width} ${scale_display_height}"
						# lecho "{x_posithon} {y_posithon}"
						# lecho "{$x_posithon} ${y_posithon}"
						GEOMETRY="--geometry=${scale_display_width}x${scale_display_height}+${x_posithon}+${y_posithon}"
						;;
					"LMAX")
						x_posithon=$(echo "scale=0; ${true_display_resolution[0]} / 2.0" | bc)
						y_posithon=0
						if [ ${panel_position} = "l" ]; then
							x_posithon=$(expr ${x_posithon} + ${panal_size[0]})
						elif [ ${panel_position} = "t" ]; then
							y_posithon=$(expr ${y_posithon} + ${panal_size[1]})
						fi
						# lecho "{scale_display_width} {scale_display_height}"
						# lecho "{$scale_display_width} ${scale_display_height}"
						# lecho "{x_posithon} {y_posithon}"
						# lecho "{$x_posithon} ${y_posithon}"
						GEOMETRY="--geometry=${scale_display_width}x${scale_display_height}+${x_posithon}+${y_posithon}"
						;;
					"MAX")
						x_posithon=$(echo "scale=0; ${display_rsolution_list[0]} - ${scale_display_width}" | bc)
						scale_display_height=$(echo "scale=0; ${display_rsolution_list[1]} / 1.2" |bc)
						y_posithon=$(echo "scale=0; ${display_rsolution_list[1]} - ${scale_display_height} -${WIN_DEPTH}" | bc)
						# echo display_rsolution_list1 ${display_rsolution_list[0]} 
						# echo scale_display_height ${scale_display_height}
						# echo y_posithon ${y_posithon} 
						if [ ${panel_position} = "b" ]; then
							scale_display_height=$(expr ${scale_display_height} - ${panal_size[1]})
							y_posithon=$(echo "scale=0; ${display_rsolution_list[1]} - ${scale_display_height} -${WIN_DEPTH} - ${panal_size[1]}" | bc)
						fi
						if [ ${panel_position} = "t" ]; then
							scale_display_height=$(echo "scale=0; ${display_rsolution_list[1]} / 1.2" |bc)
						fi
						# echo "{scale_display_width} {scale_display_height}"
						# echo "${scale_display_width} ${scale_display_height}"
						# echo "{x_posithon} {y_posithon}"
						# echo "${x_posithon} ${y_posithon}"
						GEOMETRY="--geometry=${scale_display_width}x${scale_display_height}+${x_posithon}+${y_posithon}"
					;;
				esac
			fi
			# lecho EXEC_TERMINAL_FOCUS
			# lecho ${EXEC_TERMINAL_FOCUS}
			case "${EXEC_TERMINAL_FOCUS}" in
				"ON")
					case "${EXEC_TERMINAL_ON}" in 
						"ON")
							ccerminal_window_list=$(wmctrl -lx | grep -i "${CC_TERMINAL_NAME}" | tail -n -1 | awk '{print $1}')
							# lecho ccerminal_window_list
							# lecho ${ccerminal_window_list}
							if [ -z "${ccerminal_window_list}" ]; then
								# lecho terminal_window_list
								# lecho ${terminal_window_list}
								ccerminal_window_list=$(wmctrl -lx | grep -i "terminal" | tail -n -1 | awk '{print $1}')
							fi
							sleep 0.5 && wmctrl -i -a "${ccerminal_window_list}" &
							;;
						"OFF")
							sleep 0.5 && xdotool key alt+Tab & 
							;;
					esac
				;;
			esac
		;;
	esac

	#current dir info
	local sed_home_path=$(echo "${HOME}" | sed 's/\//\\\//g')
	case "${NORMAL_SIGNAL_CODE}" in 
		"${CHDIR_CODE}")
				local display_sec_ini_path=$(echo "${CMDCLICK_CONF_DIR_PATH}" | sed 's/'${sed_home_path}'/~/')
				;;
		*)
			local display_sec_ini_path=$(echo "${SECONDS_INI_FILE_DIR_PATH}" | sed 's/'${sed_home_path}'/~/')
			;;
	esac
	# lecho "sed_home_path: ${sed_home_path}"
	# lecho "display_sec_ini_path: ${display_sec_ini_path}"
	local sed_dir_path=$(echo "${1}" | sed 's/\//\\\//g')
	case "${SIGNAL_CODE}" in 
		"${DELETE_CODE}"|"${EDIT_CODE}")
			local ini_file_list="$(ls -ultF  "${1}/" | sed 's/\*$//g' | rga ''${COMMAND_CLICK_EXTENSION}'' | awk '{print $9}' | sed  '1i ['${display_sec_ini_path}']' | sed 's/$/\t'${sed_dir_path}'/' | rga -v "${CMDCLICK_EDIT_CMD}" | rga -v "${CMDCLICK_DELETE_CMD}" | rga -v "${CMDCLICK_CHANGE_DIR_CMD}" | rga -v "${CMDCLICK_RESOLUTION_CMD}" | rga -v "${CMDCLICK_ADD_CMD}")"
			case "${ini_file_list}" in
				"") 
					local ini_file_list="$(cat <(echo "[${display_sec_ini_path}"]) <(echo "-") | sed 's/$/\t'${sed_dir_path}'/')"
					;;
			esac
			;;
		*)
			local ini_file_list="$(ls -ultF  "${1}" | sed  's/\*$//g' | rga ''${COMMAND_CLICK_EXTENSION}'' | awk '{print $9}' | sed  -e '1i ['${display_sec_ini_path}']' -e 's/$/\t'${sed_dir_path}'/')"
			case "${ini_file_list}" in
				"")
					local ini_file_list="$(cat <(echo "[${display_sec_ini_path}"]) <(echo "-") | sed 's/$/\t'${sed_dir_path}'/')"
					;;
			esac
			;;
	esac
	#デフォルト時（ジオメトリなし）のみ縦×横サイズ発動
	EXECUTE_COMMAND=""
	# echo ${x_posithon},${y_posithon},${scale_display_width},${scale_display_height}
	# GEOMETRY ${WIDTH}x${scale_display_height}+${x_posithon}+${y_posithon}
	[ -f "${HOME}/.fzf.bash" ] && . ${HOME}/.fzf.bash
	LANG="ja_JP.UTF-8"
	lxterminal --title="${WINDOW_TITLE}" -e bash "${MAIN_LIST_SH_PATH}" "${1}" "${ini_file_list}" 1>/dev/null 2>&1 &
	# SOURCE_DIR_PATH=\"${SOURCE_DIR_PATH}\"; ini_file_list=\"${ini_file_list}\"; 
	PID=$!
	while true
		do
			sleep 0.01
			lxwmId=$(wmctrl -lx | grep "lxterminal.Lxterminal" | awk '{print $1}') 
			case "${lxwmId}" in "");; *) break;; esac 
		done
	wmctrl  -r "${WINDOW_TITLE}" -e 0,${x_posithon},${y_posithon},${scale_display_width},${scale_display_height}
	wait $PID
	local status_code=$?
	# echo ${status_code}
	local IFS=$'\n' 
	VALUE=($(cat "${CMDCLICK_VALUE_SIGNAL_FILE_PATH}"))
	local IFS=$' \t' 
	# echo "VALUE0: ${VALUE[0]}"
	# echo "VALUE1: ${VALUE[1]}"
	# cat "${CMDCLICK_PASTE_SIGNAL_FILE_PATH}"
	case "${VALUE[0]}" in "") status_code=1;; *) status_code=0;; esac

	# echo "status_code ${status_code}"
	local hit_app_dir_file=$(rga --heading "${VALUE[1]}"  "${CMDCLICK_CONF_DIR_PATH}" | rga -B 1 "${CH_DIR_PATH}" | head -n 1)
 	# update app dir list order (recent used)
 	case "${hit_app_dir_file}" in 
 		"")
			local rga_path1=$(echo "${VALUE[1]}" | sed 's/'${sed_home_path}'/\\$\\{HOME\\}/')
			hit_app_dir_file=$(rga --heading "${rga_path1}" "${CMDCLICK_CONF_DIR_PATH}" | rga -B 1 "${CH_DIR_PATH}" | head -n 1)
 			case "${hit_app_dir_file}" in
 				"") 
					local rga_path2=$(echo "${VALUE[1]}"  | sed 's/'${sed_home_path}'/\\$HOME/')
					hit_app_dir_file=$(rga --heading "${rga_path2}" "${CMDCLICK_CONF_DIR_PATH}" | rga -B 1 "${CH_DIR_PATH}" | head -n 1)
					;;
			esac
			;;
	esac
	if [ -e "${hit_app_dir_file}" ]; then 
		touch "${hit_app_dir_file}"
		echo "${GREP_INC_NUM}=1" > "${CMDCLICK_CONF_INC_CMD_PATH}"
	fi
 	# lecho "status_code: ${status_code}"
 	case "${status_code}" in 
 		"1") 
			local status_list=($(cat "${CMDCLICK_PASTE_SIGNAL_FILE_PATH}"));
			cp /dev/null "${CMDCLICK_PASTE_SIGNAL_FILE_PATH}";
		;;
	esac
	# echo "status_list0 ${status_list[0]}"
	# echo "status_list1 ${status_list[1]}"
	# echo "status_list2 ${status_list[2]}"
	# echo "status_list@ ${status_list[@]}"
	# lecho "status_list: "${status_list}
	# lecho "ini_file_list: ${ini_file_list}"
	local return_value=${VALUE[0]}
	INI_FILE_DIR_PATH=${VALUE[1]}

	case "${status_code}" in 
 		"1") INI_FILE_DIR_PATH=$(echo ${status_list[2]} | sed  -e "s/^'//g" -e "s/'$//g")
			;;
	esac
	# if [ ${status_code} -eq 1 ];then INI_FILE_DIR_PATH=$(echo ${status_list[2]} | sed "s/\'//g");fi
	
	# lecho "${VALUE[@]}"
	# lecho "INI_FILE_DIR_PATH: ${INI_FILE_DIR_PATH}"
	# lecho "return_value ${return_value}"
	# lecho "$(echo "${return_value}" | rga "${CMDCLICK_EDIT_CMD}")"
	# lecho "echo ${return_value} | grep ${CMDCLICK_EDIT_CMD}"
	# lecho "return_value: ${return_value}"	
	# alter SIGNAL_CODE to return_value 
	local add_on=$(echo "${return_value}" | rga "${CMDCLICK_ADD_CMD}")
	local delete_on=$(echo "${return_value}" | rga "${CMDCLICK_DELETE_CMD}")
	local edit_on=$(echo "${return_value}" | rga "${CMDCLICK_EDIT_CMD}")
	
	local cd_dir_on=$(echo "${return_value}" | rga "${CMDCLICK_CHANGE_DIR_CMD}")
	#resolution_on=$(echo "${return_value[@]}" | grep "${CMDCLICK_RESOLUTION_CMD}")
	# lecho "${return_value} grep ${CMDCLICK_CHANGE_DIR_CMD}"
	# lecho "cd_dir_on: ${cd_dir_on}"
	# lecho "add: ${add_on}"
	# lecho "edit_on: ${edit_on}"
	case "${return_value}" in
		"") 
			SIGNAL_CODE=${EXIT_CODE}
			;;
		*)
			if [ -z "${add_on}" ] && [ -z "${delete_on}" ] && [ -z "${edit_on}" ] && [ -z "${cd_dir_on}" ] && [ -z "${resolution_on}" ];then SIGNAL_CODE=${OK_CODE};
			elif [ -n "${add_on}" ] ;then SIGNAL_CODE=${ADD_CODE}; 
			elif [ -n "${cd_dir_on}" ];then SIGNAL_CODE=${CHDIR_CODE};
			elif [ -n "${delete_on}" ];then SIGNAL_CODE=${DELETE_CODE};
			elif [ -n "${edit_on}" ];then SIGNAL_CODE=${EDIT_CODE};
			#elif [ -n "${resolution_on}" ];then SIGNAL_CODE=${RESOLUTION_CODE};
			else SIGNAL_CODE=${INDEX_CODE}; fi
		;;
	esac
	
	if expr "${status_list[0]}" : "[0-9]*$" >&/dev/null; then
		case "${status_list[0]}" in 
			"${EDIT_CODE}") SIGNAL_CODE=${EDIT_CODE} ;;
			"${ADD_CODE}") SIGNAL_CODE=${ADD_CODE} ;;
			"${CHDIR_CODE}") SIGNAL_CODE=${CHDIR_CODE} ;;
			"${RESOLUTION_CODE}") SIGNAL_CODE=${RESOLUTION_CODE} ;;
			"${DELETE_CODE}") SIGNAL_CODE=${DELETE_CODE} ;;
		esac
	fi
	# echo "DELETE_CODE ${DELETE_CODE}" 
	# echo SIGNAL_CODE ${SIGNAL_CODE}

	# CODE別処理
	local execute_file_code=0
	EXECUTE_FILE_NAME=$(echo "${return_value}" | sed  -e 's/'${CMDCLICK_DELETE_CMD}'//g' -e 's/'${CMDCLICK_EDIT_CMD}'//g' -e 's/ //g')
	
	case "${status_code}" in 
		"1") EXECUTE_FILE_NAME=$(echo ${status_list[1]} | sed  -e "s/^'//g" -e "s/'$//g") ;; 
	esac
	# echo SIGNAL_CODE ${SIGNAL_CODE}
	# echo EXECUTE_FILE_NAME ${EXECUTE_FILE_NAME}
	# echo INI_FILE_DIR_PATH ${INI_FILE_DIR_PATH}

	# lecho "SIGNAL_CODE=$SIGNAL_CODE"
	# lecho "EXECUTE_FILE_NAME: ${EXECUTE_FILE_NAME}"
	#設定変数初期化
	EXEC_TERMINAL_ON=""
	EXEC_OPEN_WHERE=""
	EXEC_TERMINAL_SIZE=""
	EXEC_TERMINAL_FOCUS=""
	EXEC_INPUT_EXECUTE=""
	EXEC_IN_EXE_DFLT_VL=""
	EXEC_BEFORE_COMMAND=""
	EXEC_AFTER_COMMAND=""
	EXEC_EXEC_WAKE=""
	EDIT_EDITOR_ON=""
}