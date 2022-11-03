#!/bin/bash

display_edit_contensts(){
  # lecho "source_cmd111: ${source_cmd}"
  edit_label=$(echo "${source_cmd}")

  #コマンド最後に空白改行なければ、追加（cmdclickワンバックスラッシュ変換の前にしないと、なぜかダメ）
  local check_sec_last_char="$(echo  "${edit_label}" | tail -n -1 | sed -e "s| ||g")"
  # lecho "check_sec_last_char: ${check_sec_last_char}"
  if [ ${#check_sec_last_char} -ge 1 ]; then
    edit_label="$(echo  "${edit_label}" | sed -e "$ a \ \n")"
  fi
  # lecho  "edit_label_last_newline: ${edit_label}"
  local edit_label=$(echo ${source_cmd::400} | sed 's/\&/\&amp;/g' | sed 's/</\&lt;/g' | sed 's/>/\&gt;/g' | sed 's/"/\&quot;/g' | sed "s/'/\&apos;/g" | sed "s/${CMDCLICK_N_CAHR}/n/g" | sed 's/'${CMDCLICK_BACKSLASH_MARK}'/\\\\/g' | sed 's/'${CMDCLICK_ONE_BACKSLASH_MARK}'/\\\\/g')
  edit_label="$(echo "${edit_label}" | sed -e "1i \ \n please edit bellow command;\n ")"
  # lecho  "edit_label: ${edit_label}"
  #ウィンドウサイズ策定
  local display_rsolution=$(xrandr | grep '*' | awk '{print $1}')
  # lecho ${display_rsolution}
  local display_rsolution_list=($(echo "${display_rsolution}" | sed -e 's|x| |g'))
  # lecho ${display_rsolution_list[@]}
  local scale_display_height=$(echo "scale=0; ${display_rsolution_list[1]} / 1.1" | bc)
  local scale_display_width=$(echo "scale=0; ${display_rsolution_list[0]} / 1.9" | bc)
  local GEOMETRY=""
  # echo variabl_contensts_value_list
  # echo "${variabl_contensts_value_list[@]}"
  case "${roop_num}" in 
    "1") local button_list=(\
        "--button  gtk-edit:${EDIT_FULL_CODE}" \
        "--button  gtk-cancel:${EXIT_CODE}" \
        "--button  gtk-ok:${OK_CODE}")
        ;;
    *) local button_list=(\
        "--button  gtk-cancel:${EXIT_CODE}" \
        "--button  gtk-ok:${OK_CODE}")
        ;;
  esac
  ini_value=$(LANG="ja_JP.UTF-8" yad --form \
    --title="${WINDOW_TITLE}" \
    --window-icon="${WINDOW_ICON_PATH}" \
    --text="${edit_label}" \
    --separator=$'\t' --item-separator="!" \
    --center \
    --scroll \
    --height=${scale_display_height} \
    --width=${scale_display_width} \
    ${button_list[@]} \
    ${variabl_contensts_field_list[@]} \
    "${variabl_contensts_value_list[@]}" \
    "${GEOMETRY}"
  )
  SIGNAL_CODE=$?
  # echo "ini_value: ${ini_value}"
}

editor_on_display(){
  local display_rsolution=$(xrandr | grep '*' | awk '{print $1}')
  # lecho ${display_rsolution}
  local display_rsolution_list=($(echo "${display_rsolution}" | sed -e 's|x| |g'))
  # lecho ${display_rsolution_list[@]}
  local scale_display_height=$(echo "scale=0; ${display_rsolution_list[1]} / 1.1" | bc)
  local scale_display_width=$(echo "scale=0; ${display_rsolution_list[0]} / 1.9" | bc)
  sleep 0.5 && "${CMDCLICK_EDITOR_CMD}" "${EDIT_FILE_PATH}" &
  editor_on_message="\n please edit code by editor \n"
  EXEC_INPUT_EXECUTE_SIGNAL=""
  case "${EXEC_INPUT_EXECUTE}" in 
    "") button_op="--button gtk-ok:${EXIT_CODE}";;
    "E") button_op=""
  esac
  yad --text="${editor_on_message}" \
      --title="${WINDOW_TITLE}" \
      --window-icon="${WINDOW_ICON_PATH}" \
      --center \
      --scroll \
      --height=${scale_display_height} \
      --width=${scale_display_width} \
      ${button_op}
    EXEC_INPUT_EXECUTE_SIGNAL=$?
    # echo "EXEC_INPUT_EXECUTE_SIGNAL: ${EXEC_INPUT_EXECUTE_SIGNAL}"
  local file_name=$(cat "${EDIT_FILE_PATH}" | grep "${INI_CMD_FILE_NAME}=" | sed 's/'${INI_CMD_FILE_NAME}'\=//g')
  if [ "${EDIT_FILE_PATH}" != "${INI_FILE_DIR_PATH}/${file_name}" ];then
    mv "${EDIT_FILE_PATH}" "${INI_FILE_DIR_PATH}/${file_name}"
  fi
  SIGNAL_CODE=${EXIT_CODE}
}

#yad用入力値反映イニファイル内容を作成
confirm_edit_contensts(){
	local display_ini_contents=$(echo  "${1}" | sed 's/\&/\&amp;/g' | sed 's/</\&lt;/g' | sed 's/>/\&gt;/g' | sed 's/"/\&quot;/g' | sed "s/'/\&apos;/g" | sed "s/${CMDCLICK_N_CAHR}/n/g")
    # lecho display_ini_contents
    # lecho "${display_ini_contents}"
    save_confirm_message="\n Do you really want to save bellow ini file ? \n"
    # lecho save_confirm_message
    # lecho "${save_confirm_message}"
    GEOMETRY="--maximized"
    GEOMETRY=""
    LANG="ja_JP.UTF-8" yad --form \
      --title="${WINDOW_TITLE}" \
      --window-icon="${WINDOW_ICON_PATH}" \
      --item-separator='!'\
      --center \
      --scroll \
      --height=${scale_display_height} \
      --width=${scale_display_height} \
      --separator=${ITEM_THREAD} \
      --field="${save_confirm_message}":LBL \
      --field="${display_ini_contents}":LBL  \
      "${GEOMETRY}"
    CONFIRM=$?
    # lecho "CONFIRM: ${CONFIRM}"
}