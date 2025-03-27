#!/bin/bash

get_usr(){
	echo "${1}" \
		| awk '{
			split($0, path_array, "/")
			print path_array[3]
		}'
}
get_desktop_path(){
	local en_desktop_path="${1}/desktop"
	if [ -d "${en_desktop_path}" ];then
		echo "${en_desktop_path}"
		return
	fi
	local kana_desktop_path="${1}/デスクトップ"
	if [ -d "${kana_desktop_path}" ];then
		echo "${kana_desktop_path}"
		return
	fi
	echo "deskotp path not found"
	exit 0
}
insert_str_to_file(){
	local insert_str="${1}"
	local file_path="${2}"
	echo "### $FUNCNAME"
	echo "${!insert_str@}: ${insert_str}"
	echo "${!file_path@}: ${file_path}"
	
	if [ -z "${insert_str}" ] \
		|| [ -z "${file_path}" ]; then
			return
	fi
	local is_insert_str=$(\
		cat "${file_path}" \
		| grep "${insert_str}"\
	)
	test -n "${is_insert_str}" \
	&& return
	echo "${insert_str}" >> ${file_path}
}

echo "type server share path ex) 192.168.0.6:/home/haumi/デスクトップ/share"
read -e -p ": " SERVER_SHARE_PATH
sudo apt-get install -y nfs-common
readonly USER_NAME=$(get_usr "${0}")
readonly HOME_PATH="/home/${USER_NAME}"
readonly DESKTOP_PATH=$(get_desktop_path ${HOME_PATH})
readonly SHARE_PATH="${DESKTOP_PATH}/haumi"
sudo mount ${SERVER_SHARE_PATH} "${SHARE_PATH}"
insert_str_to_file \
	"${SERVER_SHARE_PATH} ${SHARE_PATH} nfs defaults 0 0" \
	"/etc/fstab"
