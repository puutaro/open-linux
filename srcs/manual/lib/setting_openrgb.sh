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

readonly USER_NAME=$(get_usr "${0}")
readonly HOME_PATH="/home/${USER_NAME}"
readonly DESKTOP_PATH=$(get_desktop_path ${HOME_PATH})
readonly OPENRGB_DEB="openrgb_1.0rc2_amd64_bookworm_0fca93e.deb"
readonly OPENRGB_PATH="${DESKTOP_PATH}/${OPENRGB_DEB}"
rm -f "${OPENRGB_PATH}"
curl \
	-L "https://codeberg.org/OpenRGB/OpenRGB/releases/download/release_candidate_1.0rc2/${OPENRGB_DEB}" \
	-o "${DESKTOP_PATH}/${OPENRGB_DEB}"
sudo dpkg -i "${OPENRGB_PATH}"
readonly openrgb_which="/usr/bin/openrgb"
readonly profile_name="dram_off"
readonly openrgb_cmd="${openrgb_which} --profile ${profile_name}"
insert_str_to_file \
	"${openrgb_cmd}" \
	"${HOME_PATH}/startup.sh"
echo "your openrgb set dram_off profile by settting rgb #000000 ok? (y)"
read -e -p ": " ans
case "${ans}" in
	y) ;;
	*) exit 0
		;;
esac

sudo -u "${USER_NAME}" "${openrgb_which}"
sudo -u "${USER_NAME}"  ${openrgb_cmd}

