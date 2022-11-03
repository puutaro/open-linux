#!/bin/bash

make_ini_contensts(){
  LANG=C
  source_cmd=""
  #backslach一つを四個に
  #("${variabl_contensts_field_list[${i}]}"  ${scheme_num} "1" "${variabl_contensts_value_list[${i}]}" ${scheme_num} ${SCHEME_CHAR_NUME} ${EDIT_CHAR_NUM}  "0")
  local ini_contents_moto="${1}"
  ini_contents="${ini_contents_moto}"
  # echo "${ini_contents}"
  case "${roop_num}" in 
    "1")
        case "${EXEC_IN_EXE_DFLT_VL}" in 
          "") 
            local source_con=$(echo "${ini_contents_moto}" | sed -n '/'${SEARCH_INI_CMD_VARIABLE_SECTION_START_NAME}'/,/'${SEARCH_INI_CMD_VARIABLE_SECTION_END_NAME}'/p' | sed '/'${SEARCH_INI_CMD_VARIABLE_SECTION_START_NAME}'/d' | sed '/'${SEARCH_INI_CMD_VARIABLE_SECTION_END_NAME}'/d' | rga "^[a-zA-Z0-9_-]{1,100}=")
            ;;
          *)
            local source_con=$(eval "echo \"\${ini_contents_moto}\" ${EXEC_IN_EXE_DFLT_VL}" | sed -n '/'${SEARCH_INI_CMD_VARIABLE_SECTION_START_NAME}'/,/'${SEARCH_INI_CMD_VARIABLE_SECTION_END_NAME}'/p' | sed '/'${SEARCH_INI_CMD_VARIABLE_SECTION_START_NAME}'/d' | sed '/'${SEARCH_INI_CMD_VARIABLE_SECTION_END_NAME}'/d' | rga "^[a-zA-Z0-9:_-]{1,100}=")
            ;;
        esac
        local get_valiable=$(cat  <(echo "${source_con}") | sed -e '/^$/d' -e 's/\=$/=-/' | sed -e 's/\=/\t/' )
        if [ -z "${get_valiable}" ];then roop_num=2; get_valiable=""; fi
        ;;
  esac
  if [ ${roop_num} -ge 2 ];then
    local current_key_value=$(eval "echo \"$(echo "${ini_contents_moto}" | sed -n '/'${SEARCH_INI_SETTING_SECTION_START_NAME}'/,/'${SEARCH_INI_SETTING_SECTION_END_NAME}'/p' | sed -e '/'${SEARCH_INI_SETTING_SECTION_START_NAME}'/d' -e '/'${SEARCH_INI_SETTING_SECTION_END_NAME}'/d' | rga "^[a-zA-Z0-9_-]{1,100}=")\" ${GREP_INI_SETTING_KEY_CON}")
    # echo "current_key_value ${current_key_value}" 
    # echo "${GREP_INI_SETTING_KEY_CON}"
    local echo_key_val_con="$(bash -c "echo \"$(echo "${INI_SETTING_DEFAULT_VALUE_CONS}"  | sed -e "s/^/echo '/" -re '1,5s/([a-zA-Z0-9_-]{1,100})=(.*)/\1:CB=\2/')\" $(echo "${current_key_value}" | rga -o "^[a-zA-Z0-9_-]{1,100}" | sed -re 's/(.*)/ -e \1 /' -e '1i \| rga ' | tr -d '\n' )" | sed -re 's/(echo )/\1/')"
    # echo "echo_key_val_con ${echo_key_val_con}" 
    # echo --
    local cb_key_num=$(echo  "${echo_key_val_con}" | rga "[a-zA-Z0-9_-]{1,100}:CB=" | wc -l )
    # paste -d '' <(echo "${echo_key_val_con}" | sed "1,${cb_key_num}s/$//" | sed "1,${cb_key_num}s/$/'/" ) <(echo "${current_key_value}" | sed -r '1,'${cb_key_num}'s/([a-zA-Z0-9_-]{1,100})=(.*)/ | sed -r "s\/(\2\\\!)\/\^\\1\/"  | sed -r "s\/\\\!(\2)\/\\\!\^\\1\/"/' | sed -r "1,${cb_key_num}!s/([a-zA-Z0-9_-]{1,100})=(.*)/\2'/")
    # echo --
    local source_con=$(cat <(echo "${ini_contents_moto}" | sed -n '/'${SEARCH_INI_CMD_VARIABLE_SECTION_START_NAME}'/,/'${SEARCH_INI_CMD_VARIABLE_SECTION_END_NAME}'/p' | sed -e '/'${SEARCH_INI_CMD_VARIABLE_SECTION_START_NAME}'/d' -e '/'${SEARCH_INI_CMD_VARIABLE_SECTION_END_NAME}'/d' | rga "^[a-zA-Z0-9_-]{1,100}=")  <(bash -c "$(paste -d '' <(echo "${echo_key_val_con}" | sed "1,${cb_key_num}s/$//" | sed "1,${cb_key_num}s/$/'/" ) <(echo "${current_key_value}" | sed -r '1,'${cb_key_num}'s/([a-zA-Z0-9_-]{1,100})=(.*)/ | sed -r "s\/(\2\\\!)\/\^\\1\/"  | sed -r "s\/\\\!(\2)\/\\\!\^\\1\/"/' | sed -r "1,${cb_key_num}!s/([a-zA-Z0-9_-]{1,100})=(.*)/\2'/"))"))
    # echo "source_con ${source_con}"
    if [ ${roop_num} -eq 2 ];then 
      source_con=$(echo "${source_con}" | sed 's/^'${INI_CMD_FILE_NAME}'\=.*/'${INI_CMD_FILE_NAME}'='${EXECUTE_FILE_NAME}'/' ) 
    fi
    local get_valiable=$(echo "${source_con}"  | sed -e '/^$/d' -e 's/\=$/=-/' | sed -e 's/\=/\t/')
  fi
  # echo source_con
  # echo "${source_con}"
  # echo get_valiable
  # echo "${get_valiable}"
  all_key_con=$(echo "${source_con}" | cut -d= -f1 | sed 's/\:CB$//')
  # echo "check_only_full_edit_bool_field: ${check_only_full_edit_bool_field}"
  # echo "source_con: ${source_con}"
  source_cmd=$(echo "${ini_contents_moto}" | rga -v "^#" | rga -v "^[a-zA-Z0-9_-]{1,100}=" | sed '/^$/d')

  # echo all_key_con
  # echo "${all_key_con}"
  # echo get_valiable
  # echo "${get_valiable}"
  local IFS=$'\n'
  variabl_contensts_field_list=($(echo "${get_valiable}" | cut -f1 | sed 's/^/\-\-field\=/'))
  # echo "variabl_contensts_field_list"
  # echo ${variabl_contensts_field_list[@]}
  # echo ${#variabl_contensts_field_list[@]}
  variabl_contensts_value_list=($(echo "${get_valiable}" | cut -f2- | sed 's/^-/"-"/'))
  echo "variabl_contensts_value_list"
  echo ${variabl_contensts_value_list[@]}
  echo ${#variabl_contensts_value_list[@]}
}