#!/bin/bash
set -ue

get_usr(){
	echo "${1}" \
		| awk '{
			split($0, path_array, "/")
			print path_array[3]
		}'
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


install_protoc(){
	local proto_version=$(\
		curl -s "https://api.github.com/repos/protocolbuffers/protobuf/releases/latest" \
		| jq -r ".tag_name"\
	)
	# 3.17.3 

	export pb_rel_url="https://github.com/protocolbuffers/protobuf/releases" 
	export home_local=${HOME_PATH}/.local  
	test -d "${home_local}"  || mkdir  "${home_local}" 
	local download_url="${pb_rel_url}/download/${proto_version}/protoc-${proto_version#v}-linux-x86_64.zip"
	echo "curl -L ${download_url} -o ${home_local}/protoc.zip"
	curl -L "${download_url}" -o "${home_local}/protoc.zip" 
	local home_local_bin="${home_local}/bin"
	mkdir -p "${home_local_bin}"  
	yes | unzip "${home_local}/protoc.zip" -d "${home_local}"
	sudo chown ${USER_NAME}:${USER_NAME} -R "${home_local}"
	sudo chmod +x "${home_local_bin}/protoc"
	insert_str_to_file \
		"export PATH=\$PATH:\$HOME/.local/bin" \
		"${BASHRC_PATH}"
}		
install_mockgen(){
	go install go.uber.org/mock/mockgen@latest
	# go install github.com/golang/mock/mockgen@v1.6.0
}
readonly USER_NAME=$(get_usr "${0}")
readonly HOME_PATH="/home/${USER_NAME}"
readonly BASHRC_PATH="${HOME_PATH}/.bashrc"
install_protoc
install_mockgen

# go mock gen install
# go install go.uber.org/mock/mockgen@latest
# readonly WORKING_DIR_PATH="${HOME}/d_package"
# mkdir -p "${WORKING_DIR_PATH}"
# cd "${WORKING_DIR_PATH}"
# readonly PROTOC_proto_version=$(\
# 	curl -s "https://api.github.com/repos/protocolbuffers/protobuf/releases/latest" \
# 	| grep -Po '"tag_name": "v\K[0-9.]+'\
# )
# wget -qO protoc.zip https://github.com/protocolbuffers/protobuf/releases/latest/download/protoc-${PROTOC_proto_version}-linux-x86_64.zip
# sudo unzip -q protoc.zip bin/protoc -d /usr/local
# sudo chmod a+x /usr/local/bin/protoc
# rm -rf protoc.zip

# readonly pb_rel_url="https://github.com/protocolbuffers/protobuf/releases"
# curl -LO ${pb_rel_url}/download/v3.15.8/protoc-3.15.8-linux-x86_64.zip
# #Unzip the file under $HOME/.local or a directory of your choice. For example:
# unzip protoc-3.15.8-linux-x86_64.zip -d $HOME/.local
# #Update your environment’s path variable to include the path to the protoc executable. For example:
# export PATH="$PATH:$HOME/.local/bin"