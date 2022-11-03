#!/bin/bash

ini_editting_daialog () {
  while :
  #search_cimnt_ini $1 $2
  do
    echo "####################################################"
  	all_confirm_times=4
  	current_confirm_times=1
    local ini_contents=$(cat $2)
  	current_username=$(echo "${ini_contents}" | grep "${SETTING_USER_NAME}" | sed "s|${SETTING_USER_NAME}=||")
  	echo "[${current_confirm_times}/${all_confirm_times}] please type username (current: "${current_username}")"
    echo "ex) john,  kitamura"
    if [ -n "${current_username}" ]; then
      stty -echo && xdotool type ${current_username} && stty echo
  	fi
    read -e input_user_name
    ini_contents=$(echo -e "${ini_contents}" | sed "s|${SETTING_USER_NAME}=${current_username}|${SETTING_USER_NAME}=${input_user_name}|g")
    current_confirm_times=$((current_confirm_times+1))

    current_password=$(echo "${ini_contents}" | grep "${SETTING_PASSWORD}" | sed "s|${SETTING_PASSWORD}=||")
  	echo "[${current_confirm_times}/${all_confirm_times}] please type password (current: "${current_password}")"
    echo "ex) 123456"
    if [ -n "${current_password}" ]; then
      stty -echo && xdotool type ${current_password} && stty echo
  	fi
    read -e input_password
    ini_contents=$(echo -e "${ini_contents}" | sed "s|${SETTING_PASSWORD}=${current_password}|${SETTING_PASSWORD}=${input_password}|g")
    current_confirm_times=$((current_confirm_times+1))

    current_mnt_local_dir=$(echo "${ini_contents}" | grep "${SETTING_MNT_LOCAL_DIR}" | sed "s|${SETTING_MNT_LOCAL_DIR}=||")
  	echo "[${current_confirm_times}/${all_confirm_times}] please type mnt_local_dir (current: "${current_mnt_local_dir}")"
    echo "ex) /home/john/mnt/ken"
    if [ -n "${current_mnt_local_dir}" ]; then
      stty -echo && xdotool type ${current_mnt_local_dir} && stty echo
  	fi
    read -e input_mnt_local_dir
    ini_contents=$(echo -e "${ini_contents}" | sed "s|${SETTING_MNT_LOCAL_DIR}=${current_mnt_local_dir}|${SETTING_MNT_LOCAL_DIR}=${input_mnt_local_dir}|g" | sed "s|~|/home/${USER}|g")

    current_mnt_local_dir_full=$(echo "${input_mnt_local_dir}" | sed "s|~|/home/${USER}|g")
    if [ -d ${current_mnt_local_dir_full} ]; then
      :
    else
      echo "新しくディレクトリを作ります"
      sudo mkdir -p "${current_mnt_local_dir_full}"
    fi
  	current_confirm_times=$((current_confirm_times+1))

    current_mnt_target_dir=$(echo "${ini_contents}" | grep "${SETTING_MNT_TARGET_DIR}" | sed "s|${SETTING_MNT_TARGET_DIR}=//||")
  	echo "[${current_confirm_times}/${all_confirm_times}] please type mnt_target_dir (current: "${current_mnt_target_dir}")"
    echo "ex) 192.168.0.8/share, ken/temp (ip or dnsname / share folder name)"
    if [ -n "${current_mnt_target_dir}" ]; then
      stty -echo && xdotool type ${current_mnt_target_dir} && stty echo
    fi
  	read -e input_mnt_target_dir
    ini_contents=$(echo -e "${ini_contents}" | sed "s|${SETTING_MNT_TARGET_DIR}=//${current_mnt_target_dir}|${SETTING_MNT_TARGET_DIR}=//${input_mnt_target_dir}|g")

  	echo "######################################################"
  	echo -e "${ini_contents}"
  	echo "######################################################"
  	echo "above setting file ok ? (Enter/e)"
  	read CONFIRM
  	if [ "${CONFIRM}" = "e" ]; then
      echo "ok, please re-editting $2" 
    else
      echo -e "${ini_contents}" > $2
      break
    fi
  done
}
