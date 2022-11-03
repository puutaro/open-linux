#!/bin/bash

add_cmd_ini_file(){
	LANG=C
	if [ -n "$1" ]; then
		local source_cmd="$1" 
		#特殊文字以外を取得
		local array_command=($(echo "${source_cmd}" | sed 's|[^a-zA-Z0-9$_]| |g' | sed -e 's|[$]| \$|g'))
		lecho "source_cmd: ${source_cmd}"
		lecho "array_command: ${array_command[@]}"

		#変数とコマンド文字列に分けて取得
		local v_ary_num=0
		local cmd_ary_num=0
		for val in "${array_command[@]}"
		do
			if [ ${val:0:1} = '$' ]; then
				if [ ${#val} -le 2 ]; then continue; fi
				local v_roop_continue=0
				for v_el in ${variabl_array[@]}
				do
					if [ "${val}" == "${v_el}" ];then
						v_roop_continue=$((${v_roop_continue} + 1))
						break
					fi
				done
				if [ ${v_roop_continue} -eq 1 ];then continue; fi
				local variabl_array[v_ary_num]="${val}"
				v_ary_num=$(expr $v_ary_num + 1)
			else
				if [ -n "${val}" ]; then
					local cmd_base_array[cmd_ary_num]=${val}
					cmd_ary_num=$(expr $cmd_ary_num + 1)
				fi
			fi
		done

		#iniファイル名策定のためコマンド文字列結合
		for val in "${cmd_base_array[@]}"
		do
			local ini_file_name+="_${val}"
		done
		ini_file_name=$(edit_replace_for_sed  "${ini_file_name}")
		ini_file_name=$(sckash_sinbol "${ini_file_name}" | sed "s/${CMDCLICK_N_CAHR}/n/g")
		lecho "BEFORE prefixini_file_name: ${ini_file_name}"
		#iniファイル名の接頭番号策定し、結合
		prefix_ini_file_name=$(($RANDOM % 100))
		local ini_file_name="${prefix_ini_file_name}_${ini_file_name:1:${FILE_NAME_LENGH}}${COMMAND_CLICK_EXTENSION}"
		lecho "AFTER prefixini_file_name: ${ini_file_name}"

		#iniファイル内容であるコマンドを取得(バックスラッシュ１つをを四個に（システム上は４個で一つ）)
		local ini_file_source="$(echo "${source_cmd}")"
		lecho "ini_file_source: ${ini_file_source}"
		lecho "BEFORE ini_file_source1: ${ini_file_source}"
		local ini_file_source="$(echo "${ini_file_source}" | sed -e "1i ${INI_CMD_SECTION_NAME}")"
		#空白改行挿入
		local ini_file_source="$(echo "${ini_file_source}" | sed -e "$ a \ \n")"
		#コマンド変数セクション作成開始
		local ini_file_source="$(echo "${ini_file_source}" | sed -e "$ a ${INI_CMD_VARIABLE_SECTION_NAME}")"
		#ini_file_source="$(echo "${ini_file_source}" | sed "$ a ${INI_SOURCE_COMMAND_DESCRITTION}=${source_cmd}")"
		lecho "BEFORE ini_file_source2: ${ini_file_source}"
		#コマンド変数を挿入
		for val in "${variabl_array[@]}"
		do
			ini_file_source="$(echo "${ini_file_source}" | sed -e "$ a ${val}=")"
		done
		ini_file_source="$(echo "${ini_file_source}")"
		ini_file_source="$(echo "${ini_file_source}" | sed -e "$ a \ \n")"
		ini_file_source="$(echo "${ini_file_source}" | sed -e "$ a ${INI_SETTING_SECTION_NAME}")"
		lecho "BEFORE2 ini_file_source: ${ini_file_source}"
		#セッティングセクション作成開始
		local ini_setting_list_length=$(expr ${#INI_SETTING_KEY_LIST[@]} - 1)
		for i in $(seq 0 ${ini_setting_list_length})
		do
			local key=${INI_SETTING_KEY_LIST[i]}
			if [ "${key}" = "${INI_CMD_FILE_NAME}" ]; then
				local val=$(edit_replace_for_sed  "${ini_file_name}")
				val=$(sckash_sinbol "${val}" | sed "s/${CMDCLICK_N_CAHR}/n/g")
			else
				local val=${INI_SETTING_DEFAULT_GAIN_LIST[i]}
			fi
			ini_file_source="$(echo "${ini_file_source}" | sed -e "$ a ${key}=${val}")"
		done
		lecho  "AFTER ini_file_source: ${ini_file_source}"
		echo  "${ini_file_source}" > "$2/${ini_file_name}"
	fi
}

#コマンドをユーザー入力フォームで取得
create_command_form(){
	local display_rsolution=$(xrandr | grep '*' | awk '{print $1}')
	# lecho ${display_rsolution}
	local display_rsolution_list=($(echo "${display_rsolution}" | sed -e 's|x| |g'))
	# lecho ${display_rsolution_list[@]}
	local scale_display_height=$(echo "scale=0; ${display_rsolution_list[1]} / 1.1" | bc)
	local scale_display_width=$(echo "scale=0; ${display_rsolution_list[0]} / 1.9" | bc)
	local temp_file_name="$(($RANDOM % 1000))${COMMAND_CLICK_EXTENSION}"
	local temp_file_path="${INI_FILE_DIR_PATH}/${temp_file_name}"
	local default_sh_con=$(cat <(echo "${CMDCLICK_USE_SHELL}") <(echo -e "") <(echo "${INI_SETTING_SECTION_START_NAME}")  <(echo "${INI_SETTING_DEFAULT_GAIN_CON}" | sed -r "s/(${INI_CMD_FILE_NAME}=)/\1${temp_file_name}/") <(echo "${INI_SETTING_SECTION_END_NAME}") <(echo -e "\n") <(echo "${INI_CMD_VARIABLE_SECTION_DEFAULT}")   <(echo -e "\n") <(echo "${SEARCH_INI_CMD_SECTION_START_NAME}") <(echo -e "\n "))
	echo "${default_sh_con}" > "${temp_file_path}"
	sleep 0.1 && "${CMDCLICK_EDITOR_CMD}" "${temp_file_path}" &
	local add_confirm="Do you really want to add shell file ?"
	LANG="ja_JP.UTF-8"
	yad --form \
      --title="${WINDOW_TITLE}" \
      --window-icon="${WINDOW_ICON_PATH}" \
      --item-separator='!'\
      --center \
      --scroll \
      --height=${scale_display_height} \
      --width=${scale_display_width} \
      --field="\n ${add_confirm} ? \n  ${EXECUTE_FILE_NAME} \n\n":LBL "" \
      "${GEOMETRY}"
    local CONFIRM=$?
	# echo CONFIRM ${CONFIRM}
	case "${CONFIRM}" in 
		"252"|"1")
			if [ -e "${temp_file_path}" ];then rm -f "${temp_file_path}";fi
			local seed_code=${OK_CODE}
			;;
		*) local seed_code=${EXIT_CODE}
			;;
	esac
	# lecho "seed_code: ${seed_code}"
	if [ ${seed_code} -eq ${EXIT_CODE} ] || [ ${seed_code} -ge ${FORCE_EXIT_CODE} ]; then
		SIGNAL_CODE=${EXIT_CODE}
	elif [ ${seed_code} -eq ${OK_CODE} ]; then
		SIGNAL_CODE=${OK_CODE}
	fi
	# lecho "SIGNAL_CODE: ${SIGNAL_CODE}"
	# lecho "BEFORE_CRANGING CREATE_SOURCE_CMD: ${CREATE_SOURCE_CMD}"
	if [ -e "${temp_file_path}" ];then 
		local ini_rename_file_name=$(cat "${temp_file_path}" | grep "${INI_CMD_FILE_NAME}="| cut -d= -f2)
		if [ "${ini_rename_file_name}" != "${temp_file_name}" ]; then
	        mv "${temp_file_path}" "${INI_FILE_DIR_PATH}/${ini_rename_file_name}"
	    fi
	fi
	# lecho "AFTER_CRANGING CREATE_SOURCE_CMD: ${CREATE_SOURCE_CMD}"
	# lecho "AFTER_CRANGING SIGNAL_CODE: ${SIGNAL_CODE}"
}