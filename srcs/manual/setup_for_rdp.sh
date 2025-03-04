#!/bin/bash

readonly CUR_DIR_PATH="$(dirname $0)"
readonly LIB_DIR_PATH="${CUR_DIR_PATH}/lib"
readonly set_xdg_desk_portal_path="${LIB_DIR_PATH}/set_xdg_desk_portal.sh"
readonly set_xrdp_pulse_audio_path="${LIB_DIR_PATH}/set_xrdp_pulse_audio.sh"
readonly usr_name=$(\
	echo "${CUR_DIR_PATH}" \
	| awk '{
		split($0, path_array, "/")
		print path_array[3]
	}'\
)
readonly use_home_path="/home/${usr_name}"
cd "${use_home_path}"
bash "${set_xdg_desk_portal_path}"
bash "${set_xrdp_pulse_audio_path}"