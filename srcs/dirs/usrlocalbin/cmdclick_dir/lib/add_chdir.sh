#!/bin/bash

add_cmd="yad --form \
		    --title=\"\${WINDOW_TITLE}\" \
		    --window-icon=\"\${WINDOW_ICON_PATH}\" \
		    --item-separator='!'\
		    --center \
		    --scroll \
		    --height=\${scale_display_height} \
		    --width=\${scale_display_width}"

#コマンドをユーザー入力フォームで取得
create_chdir_command_form(){
	local temp_file_name="$(($RANDOM % 1000))${COMMAND_CLICK_EXTENSION}"
	local temp_file_path="${INI_FILE_DIR_PATH}/${temp_file_name}"
	# open fd
	exec 3>&1
	# Store data to $VALUES variable
	#ウィンドウサイズ策定
  local display_rsolution=$(xrandr | grep '*' | awk '{print $1}')
  # lecho ${display_rsolution}
  local display_rsolution_list=($(echo "${display_rsolution}" | sed -e 's|x| |g'))
  # lecho ${display_rsolution_list[@]}
  local scale_display_height=$(echo "scale=0; ${display_rsolution_list[1]} / 1.1" | bc)
  local scale_display_width=$(echo "scale=0; ${display_rsolution_list[0]} / 1.9" | bc)
  # echo variabl_contensts_value_list
  # echo "${variabl_contensts_value_list[@]}"
  LANG="ja_JP.UTF-8"
  CREATE_CHDIR_PATH=$(eval "${add_cmd}\
  	--text=\"\n${ADD_CD_PATH_MESSAGE}\n\" \
    --field=\"${CH_DIR_PATH}\"")
	SIGNAL_CODE=$?
	CREATE_CHDIR_PATH=$(echo "${CREATE_CHDIR_PATH}" | tr -d '|')
	case "$(eval "echo ${CREATE_CHDIR_PATH}")" in 
		"${CMDCLICK_ROOT_DIR_PATH}") 
			eval "${add_cmd} \
			--field=\"\n\n forbidden make root dir: ${CREATE_CHDIR_PATH}\":LBL"
			SIGNAL_CODE=${CHECK_ERR_CODE}
			;;
		"") ;;
		*)
			local err_signal=""
			case "$(eval "echo \"${CREATE_CHDIR_PATH}\"" | rga "^/[a-zA-Z][a-zA-Z/._ -]*$" || e=$?)" in
				"") err_signal=1;;
			esac
			echo err_signal1 ${err_signal} 
			case "$(eval "echo \"${CREATE_CHDIR_PATH}\"" | rga "[^a-zA-Z0-9/_-]"  || e=$?)" in
				"") ;;
				*) err_signal=1;;
			esac 
			echo err_signal2 ${err_signal}
			case "${err_signal}" in 
				"1") 
					disp_create_chdir_path=$(echo "${CREATE_CHDIR_PATH}" | sed -re 's/([^a-zA-Z0-9_])/\\\1/g' -e 's/\&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' -e 's/"/\&quot;/g' -e "s/'/\&apos;/g")
					# echo disp_create_chdir_path "${disp_create_chdir_path}"
					local path_err_message=$(echo -e "type path is illegular, specific char only '-' , '_' , and '/'  \n\n  ${disp_create_chdir_path}")
					eval "${add_cmd} \
						--field=\"\n ${path_err_message} \n\n\":LBL"
					SIGNAL_CODE=${CHECK_ERR_CODE}
					;;
				*) SIGNAL_CODE=${OK_CODE}
					;;
			esac
			;;
	esac
	# echo "AFTER_CRANGING CREATE_CHDIR_PATH: ${CREATE_CHDIR_PATH}"
	# echo "AFTER_CRANGING SIGNAL_CODE: ${SIGNAL_CODE}"
}

add_chdir_cmd_ini_file(){
	LANG="ja_JP.UTF-8"
	if [ -n "${1}" ]; then
		eval "mkdir -p \"${1}\""
		local ini_file_name=$(echo "${1}" | sed -e 's/[^a-zA-Z0-9_./-]//g' -e 's/\//\_/g' -e 's/^\_//' -e 's/^/cd\_/' -e 's/$/'${COMMAND_CLICK_EXTENSION}'/')
		# lecho "ini_file_name: ${ini_file_name}"
		local add_contents=$(cat <(echo "${add_contents}") <(echo "SED_TARGET_PATH=\"${CMDCLICK_APP_LIST_PATH}\"") <(echo "sed_ch_dir_path=\$(echo \$${CH_DIR_PATH} | sed -e 's/\\//\\\\\//g' -e 's/\./\\\\\./g')" | sed '/^$/d'))
		# sed -e '/'${sed_ch_dir_path}'/d' -e "1i${sed_ch_dir_path}" -i "${SED_TARGET_PATH}"
		add_contents=$(cat <(echo "${add_contents}") <(echo "sed -e '/'\${sed_ch_dir_path}'/d' -e \"1i\${sed_ch_dir_path}\" -i \"\${SED_TARGET_PATH}\""))
		local ini_file_source=$(cat <(echo "${CMDCLICK_USE_SHELL}") <(echo -e "") <(echo "${INI_SETTING_SECTION_START_NAME}")  <(echo "${INI_SETTING_DEFAULT_GAIN_CON}" | sed -e 's/'${INI_TERMINAL_ON}'=.*/'${INI_TERMINAL_ON}'=OFF/' -re "s/(${INI_CMD_FILE_NAME}=)/\1${ini_file_name}/") <(echo "${INI_SETTING_SECTION_END_NAME}") <(echo -e "\n") <(echo "${INI_CMD_VARIABLE_SECTION_DEFAULT}" | sed "2i${CH_DIR_PATH}=${1}") <(echo -e "\n") <(echo "${SEARCH_INI_CMD_SECTION_START_NAME}") <(echo "${add_contents}"))
		
		# lecho "ini_file_source: ${ini_file_source}"
		#iniファイル名策定のためコマンド文字列結合
		# lecho  "add_chdir_cmd_ini_file::AFTER ini_file_source: ${ini_file_source}"
		local ini_file_path="${CMDCLICK_CONF_DIR_PATH}/${ini_file_name}"
		echo  "${ini_file_source}" > "${ini_file_path}" &
	fi
}
