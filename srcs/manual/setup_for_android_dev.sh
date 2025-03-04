#!/bin/bash


readonly CUR_DIR_PATH="$(dirname $0)"
readonly LIB_DIR_PATH="${CUR_DIR_PATH}/lib"
readonly set_jetbrains_toolbox_path="${LIB_DIR_PATH}/set_toolbox.sh"
readonly usr_name=$(\
	echo "${CUR_DIR_PATH}" \
	| awk '{
		split($0, path_array, "/")
		print path_array[3]
	}'\
)
readonly use_home_path="/home/${usr_name}"
cd "${use_home_path}"
bash "${set_jetbrains_toolbox_path}"
