#!/bin/bash
LANG="ja_JP.UTF-8"
delete_cmd="yad --form \
    --title=\"\${WINDOW_TITLE}\" \
    --window-icon=\"\${WINDOW_ICON_PATH}\" \
    --item-separator='!'\
    --center \
    --scroll \
    --height=\${scale_display_height} \
    --width=\${scale_display_width}"
#バックスラッシュの扱い
#ファイルから読み込むとき、\\\\を\としてCMDCLICK_BACKSLASH_MARKへ変換
#ファイルへ出力するとき、\を\\\\とする
#メモリ展開しているときは対で変換
# ※yadへの表示時のみ、\を\\とする（エスケープのため）
#バックスラッシュバグ対策
ajust_delete_backslach(){
  echo "${1}" | sed "s/n/${CMDCLICK_N_CAHR}/g" | sed 's/\\\\\\\\/'${CMDCLICK_BACKSLASH_MARK}'/g' | sed 's/\\\\\\/'${CMDCLICK_ONE_BACKSLASH_MARK}'/g' | sed 's/\\\\/'${CMDCLICK_ONE_BACKSLASH_MARK}'/g' | sed 's/\\/'${CMDCLICK_ONE_BACKSLASH_MARK}'/g'
}

delete_cmd(){
	local delete_contents=$(cat "${DELETE_FILE_PATH}")
  local delete_contents=$(echo "${delete_contents}" | sed 's/\\/\\\\\\\\/g')
  delete_contents=$(ajust_delete_backslach "${delete_contents}")
	# echo delete_contents1
	# echo "${delete_contents}"
  local display_rsolution=$(xrandr | grep '*' | awk '{print $1}')
  # echo ${display_rsolution}
  local display_rsolution_list=($(echo "${display_rsolution}" | sed -e 's|x| |g'))
  # echo ${display_rsolution_list[@]}
  scale_display_height=$(echo "scale=0; ${display_rsolution_list[1]} / 1.1" |bc)
  scale_display_width=$(echo "scale=0; ${display_rsolution_list[0]} / 1.9" |bc)
  delete_contents="$(echo "${delete_contents}" | sed 's/\&/\&amp;/g' | sed 's/</\&lt;/g' | sed 's/>/\&gt;/g' | sed 's/"/\&quot;/g' | sed "s/'/\&apos;/g" | sed "s/${CMDCLICK_N_CAHR}/n/g" | sed 's/'${CMDCLICK_BACKSLASH_MARK}'/\\\\/g' | sed 's/'${CMDCLICK_ONE_BACKSLASH_MARK}'/\\\\/g')"
  # echo delete_contents2
  # echo "${delete_contents}"
  eval "${delete_cmd} \
    --field=\"\n Do you really want to delete bellow ini file ? \n  \${EXECUTE_FILE_NAME} \n\n\":LBL \
    --field=\"\${delete_contents}\":LBL"
  local CONFIRM=$?
  # echo ${CONFIRM}
  # echo "${INI_FILE_DIR_PATH}/${EXECUTE_FILE_NAME}"
  if [ ${CONFIRM} -eq ${EXIT_CODE} ] || [ ${CONFIRM} -ge ${FORCE_EXIT_CODE} ]; then
  	:
  else
    case "${CHDIR_SIGNAL_CODE}" in
      "${DELETE_CODE}")
        local delete_dir_path=$(cat "${DELETE_FILE_PATH}" | rga "^${CH_DIR_PATH}=" | head -n 1 | sed 's/^'${CH_DIR_PATH}'\=//')
        local cd_delete_message=$(cat <(echo " ") <(echo "Would you like to delete bellow APP dir ?") <(echo " ") <(echo -e "\t${delete_dir_path}"))
        eval "${delete_cmd} \
          --field=\"\n ${cd_delete_message} \n\n\":LBL" 
        local CONFIRM_APP=$?
        local delete_dir_path=$(eval "echo ${delete_dir_path}")
        case "${CONFIRM_APP}" in  
          "${OK_CODE}") rm -rf ${delete_dir_path};;
        esac
        ;;
    esac
  	rm -f "${DELETE_FILE_PATH}"
  fi
}