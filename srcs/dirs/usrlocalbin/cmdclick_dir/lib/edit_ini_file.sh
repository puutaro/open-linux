#!/bin/bash

edit_ini_gui(){
  LANG=C
  local roop_num=0
  ini_contents=""
  EDIT_FILE_NAME="${1}"
  EDIT_FILE_PATH="${INI_FILE_DIR_PATH}/${1}"
  while :
  do
    roop_num=$((${roop_num} + 1))
    # lecho ${roop_num}
    if [ ${roop_num} -eq 1 ];then local ini_contents_moto=$(cat "${EDIT_FILE_PATH}");
    elif [ ${roop_num} -ge 2 ];then local ini_contents_moto=$(echo "${ini_contents}" | sed 's/\\\\/\\/g');fi
    # lecho  "ini_contents:edit:0.3: ${ini_contents}"
    # lecho  "ini_contents:edit:0.4: ${ini_contents_moto}"
    # echo "EDIT_EDITOR_ON: ${EDIT_EDITOR_ON}"
    if [ "${EDIT_EDITOR_ON}" != "ON" ];then
      make_ini_contensts "${ini_contents_moto}"
      # lecho  "ini_contents:edit:0.5: ${ini_contents}"
      display_edit_contensts ;
      ini_value=$(echo "${ini_value}" | tr '\t' '\n')
    fi
    if [ "${EDIT_EDITOR_ON}" == "ON" ];then editor_on_display; fi
    if [ ${SIGNAL_CODE} -eq ${EXIT_CODE} ] || [ ${SIGNAL_CODE} -ge ${FORCE_EXIT_CODE} ]; then break; fi
    # echo "ini_value11: ${ini_value}"
    # lecho  "ini_contents:edit:1: ${ini_contents}"
    convert_input_value "${ini_value}"
    check_ini_file "${ini_contents}" "stdout"
    # echo SIGNAL_CODE ${SIGNAL_CODE}
    # lecho  "ini_contents:edit:2: ${ini_contents}"
    if [ ${SIGNAL_CODE} -eq ${CHECK_ERR_CODE} ];then roop_num=$(( ${roop_num} - 1 )); continue; fi
    if [ ${SIGNAL_CODE} -eq ${EDIT_FULL_CODE} ];then continue; fi
    # lecho  "ini_contents:edit:3: ${ini_contents}" 
    case "${EXEC_IN_EXE_DFLT_VL}" in 
      "") confirm_edit_contensts "${ini_contents}" ;;
      *) CONFIRM=0 ;;
    esac
    #yad用入力値反映イニファイル内容を作成
    if [ "${CONFIRM}" -eq 1 ]; then
      echo "ok, please re-editting" 
    elif [ "${CONFIRM}" -eq 0 ]; then
      echo "ok, saving edited"
      echo "${INI_CMD_FILE_NAME}"
      local ini_rename_file_name=$(echo -e "${ini_contents}" | grep "${INI_CMD_FILE_NAME}="| cut -d= -f2-)
      # lecho ini_rename_file_name
      # lecho "${ini_rename_file_name}"
      # lecho ini_contents_bsla_before
      # lecho "${ini_contents}"
      #backslachを四個を一つに戻す
      ini_contents=$(echo "${ini_contents}" | sed 's/\\\\/\\/g')
      # lecho ini_contents_bsla_after
      # lecho "${ini_contents}"
      if [ "${ini_rename_file_name}" != "${EDIT_FILE_NAME}" ]; then
        mv "${EDIT_FILE_PATH}" "${INI_FILE_DIR_PATH}/${ini_rename_file_name}"
      fi
        echo "${ini_contents}" > "${INI_FILE_DIR_PATH}/${ini_rename_file_name}"
        touch "${INI_FILE_DIR_PATH}/${ini_rename_file_name}"
      break
    else
      break
    fi
  done

}