#!/bin/bash

execute_cimount(){
	local username="$(echo $(cat $1 | grep "${SETTING_USER_NAME}=" | sed "s|${SETTING_USER_NAME}=||g"))"
	local password="$(echo $(cat $1 | grep "${SETTING_PASSWORD}=" | sed "s|${SETTING_PASSWORD}=||g"))"
	local mnt_local_dir="$(echo $(cat $1 | grep "${SETTING_MNT_LOCAL_DIR}=" | sed "s|${SETTING_MNT_LOCAL_DIR}=||g"))"
	local mnt_target_dir="$(echo $(cat $1 | grep "${SETTING_MNT_TARGET_DIR}=" | sed "s|${SETTING_MNT_TARGET_DIR}=||g"))"
	sudo mount -t cifs -o username=${username},password=${password},uid=1000,gid=1000 "${mnt_target_dir}" "${mnt_local_dir}"
}