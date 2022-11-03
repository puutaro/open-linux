#!/bin/bash

search_cimnt_ini(){
	echo "##################################################################"
	if [ ! -e $2 ]; then
		REWRITE="yes"
		echo "REWRITE: ${REWRITE} | file locate or name err ("$2")"	
	fi
	if [ ! -s $2 ]; then
		REWRITE="yes"
		echo "REWRITE: ${REWRITE} | blank file ("$2")"	
	fi
	if [ ${REWRITE} = "no" ]; then
		local ini_contents=$(cat $2)
		local check_user_name=$(echo -e "${ini_contents}" | grep "${SETTING_USER_NAME}=" | sed "s|${SETTING_USER_NAME}=||g")
		if [ -z "${check_user_name}" ]; then
			REWRITE="yes"
			echo "REWRITE: ${REWRITE} | user name err"
			echo "${check_user_name}"
		fi

		local check_password=$(echo -e "${ini_contents}" | grep "${SETTING_PASSWORD}=" | sed "s|${SETTING_PASSWORD}=||g")
		if [ -z "${check_password}" ]; then
			REWRITE="yes"
			echo "REWRITE: ${REWRITE} | pwd setting err"
			echo "${check_password}"
		fi

		local check_mnt_local_dir=$(echo -e "${ini_contents}" | grep "${SETTING_MNT_LOCAL_DIR}=" | sed "s|${SETTING_MNT_LOCAL_DIR}=||g")
		if [ -z "${check_mnt_local_dir}" ]; then
			REWRITE="yes"
			echo "REWRITE: ${REWRITE} | mnt_local_dir setting err "
			echo "${check_mnt_local_dir}"
		fi

		local check_mnt_target_dir=$(echo -e "${ini_contents}" | grep "${SETTING_MNT_TARGET_DIR}=" | sed "s|${SETTING_MNT_TARGET_DIR}=//||g")
		if [ -z "${check_mnt_target_dir}" ]; then
			REWRITE="yes"
			echo "REWRITE: ${REWRITE} | mnt_target_dir setting err "
			echo "${check_mnt_target_dir}"
		fi
	fi
	echo "##################################################################"
	if [ ${REWRITE} = "yes" ]; then
		echo "REWRITE: ${REWRITE} | above err "
		local ini_contents_default=$(cat $1)
		ini_contents_default=$(echo "${ini_contents_default}" | sed "s|${SETTING_USER_NAME}=|${SETTING_USER_NAME}=${check_user_name}|g")
		ini_contents_default=$(echo "${ini_contents_default}" | sed "s|${SETTING_PASSWORD}=|${SETTING_PASSWORD}=${check_password}|g")
		ini_contents_default=$(echo "${ini_contents_default}" | sed "s|${SETTING_MNT_LOCAL_DIR}=|${SETTING_MNT_LOCAL_DIR}=${check_mnt_local_dir}|g")
		ini_contents_default=$(echo "${ini_contents_default}" | sed "s|${SETTING_MNT_TARGET_DIR}=//|${SETTING_MNT_TARGET_DIR}=//${check_mnt_target_dir}|g")
		echo -e "${ini_contents_default}" > "$2"
	else
		cat "$2" > "$2".bk
	fi
}
