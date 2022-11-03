#!/bin/bash

#!/bin/bash
check_ini_file(){
	LANG=C
	local rewrite="no"
	case "${2}" in 
		"")
			local validate_err_message="\tvalidation err: "
			if [ ! -e "$1" ]; then
				rewrite="yes"
				validate_err_message+="file locate or name err ("$1")"
			fi
			case "${rewrite}" in "no") local ini_contents=$(cat "$1");; esac
			;;
		*) local ini_contents="${1}" 
			;;
	esac

	#セクションネームをチェック
	case "${rewrite}" in 
		"no")
		    # lecho "ini_contents ${ini_contents}"
		    local get_cmd_sec_num=$(echo "${ini_contents}" | rga -e "${SEARCH_INI_CMD_VARIABLE_SECTION_START_NAME}" -e "${SEARCH_INI_CMD_VARIABLE_SECTION_END_NAME}" | wc -l)
		    case "${get_cmd_sec_num}" in 
		    	"2");;
				*) 
					case "${get_cmd_sec_num}" in
						"0");;
						*)
							rewrite="yes"
				    		local validate_err_message+=" CMD_SECTION_HOLDER NUM ERR, "
				  			;;
					esac 
					
			esac

			local get_cmd_sec_uniq_num=$(echo "${ini_contents}" | rga -e "${SEARCH_INI_CMD_VARIABLE_SECTION_START_NAME}$" -e "${SEARCH_INI_CMD_VARIABLE_SECTION_END_NAME}$" | uniq | wc -l)
			case "${get_cmd_sec_num}" in 
		    	"2");;
				*) 
					case "${get_cmd_sec_num}" in
						"0");;
						*)
							rewrite="yes"
				    		local validate_err_message+=" CMD_SECTION_HOLDER CONBI ERR, "
				  			;;
					esac 
					
			esac

			local get_set_sec_num=$(echo "${ini_contents}" | rga -e "${SEARCH_INI_SETTING_SECTION_START_NAME}" -e "${SEARCH_INI_SETTING_SECTION_END_NAME}" | wc -l)
			case "${get_set_sec_num}" in 
		    	"2");;
				*) 
					case "${get_set_sec_num}" in
						"0");;
						*)
							rewrite="yes"
				    		local validate_err_message+=" SETTING_SECTION_HOLDER NUM ERR, "
				  			;;
					esac 
			esac

		    local get_set_sec_uniq_num=$(echo "${ini_contents}" | rga -e "${SEARCH_INI_SETTING_SECTION_START_NAME}$" -e "${SEARCH_INI_SETTING_SECTION_END_NAME}$" | uniq | wc -l)
		    case "${get_set_sec_uniq_num}" in 
		    	"2");;
				*) 
					case "${get_set_sec_uniq_num}" in
						"0");;
						*)
							rewrite="yes"
				    		local validate_err_message+="SETTING_SECTION_HOLDER CONBI ERR, "
				  			;;
					esac 
			esac
			local validate_source_con=$(cat <(echo "${ini_contents}" | sed -n '/'${SEARCH_INI_CMD_VARIABLE_SECTION_START_NAME}'/,/'${SEARCH_INI_CMD_VARIABLE_SECTION_END_NAME}'/p' | sed '/'${SEARCH_INI_CMD_VARIABLE_SECTION_START_NAME}'/d' | sed '/'${SEARCH_INI_CMD_VARIABLE_SECTION_END_NAME}'/d' | rga "^[a-zA-Z0-9_-]{1,100}=") <(echo "${ini_contents}" | sed -n '/'${SEARCH_INI_SETTING_SECTION_START_NAME}'/,/'${SEARCH_INI_SETTING_SECTION_END_NAME}'/p' | sed '/'${SEARCH_INI_SETTING_SECTION_START_NAME}'/d' | sed '/'${SEARCH_INI_SETTING_SECTION_END_NAME}'/d' | rga "^[a-zA-Z0-9_-]{1,100}=")  | sed '/^$/d' )
			echo validate_source_con
			echo "${validate_source_con}"
			local get_blank_no_include_quote_err=$(echo "${validate_source_con}" | rga "\s" | rga -e "^[a-zA-Z0-9_-]{1,100}=[^\"']" -e "[^\"']$"  | rga -o "^[a-zA-Z0-9_-]{1,100}=" | sed 's/^/\t\t/')
			if [ -n "${get_blank_no_include_quote_err}"  ];then 
				rewrite="yes"
				local validate_err_message+=$(cat <(echo " blank isn't included by quote in bellow field") <(echo "${get_blank_no_include_quote_err}"))
			fi
			;;
	esac
	# lecho "rewrite: ${rewrite}"
	# lecho "validate_err_message: ${validate_err_message}"
	case "${1}" in 
		"${INI_FILE_DIR_PATH}/")
			rewrite="no"
			SIGNAL_CODE=${INDEX_CODE}
			;;
	esac

	case "${rewrite}" in 
		"yes")
			case "${2}" in 
				"")
					local check_message=$(cat <(echo "bellow err, please ini file manual repair or delete \n (FILEPATH: "$1")") <(echo "${validate_err_message}"))
					;;
				*)
					local check_message=$(cat <(echo "bellow err, please re-edit  \n\n") <(echo "  ${validate_err_message}"))
					;;
			esac
			# lecho "${check_message}"
			local display_rsolution=$(xrandr | grep '*' | awk '{print $1}')
			local display_rsolution_list=($(echo "${display_rsolution}" | sed -e 's|x| |g'))
			local scale_display_height=$(echo "scale=0; ${display_rsolution_list[1]} / 1.1" |bc)
			local scale_display_width=$(echo "scale=0; ${display_rsolution_list[0]} / 1.9" |bc)
			LANG="ja_JP.UTF-8"
			yad --form \
				--title="${WINDOW_TITLE}" \
				--window-icon="${WINDOW_ICON_PATH}" \
				--center \
				--height=${scale_display_height} \
      			--width=${scale_display_width} \
				--item-separator='!'\
				--field="\n bellow err, please ini file manual repair or delete \n (FILEPATH: "$1")\n":LBL   "" \
				--field="${check_message}":LBL \
				--button=gtk-ok:${OK_CODE} 
			# dialog --title "${WINDOW_TITLE}"  --no-shadow --msgbox "${check_message}" "${INFO_BOX_DEFAULT_SIZE[@]}"
			# clear
			SIGNAL_CODE=${CHECK_ERR_CODE}
			# lecho SIGNAL_CODE
			;;
	esac
}
