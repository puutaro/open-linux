#!/bin/bash

get_cur_secret_key(){
	gpg \
		--list-secret-keys \
		--keyid-format=long \
	| grep ed25519 \
	| aku cut -f 2 \
	| aku tr "ed25519/"
}
export -f get_cur_secret_key

generate_secret_key(){
	gpg --full-generate-key
	gpg --list-secret-keys --keyid-format=long
}

export_public_key(){
	local cur_secret_key=$(get_cur_secret_key)
	gpg \
		--armor \
		--export "${cur_secret_key}"
	git config \
		--global user.signingkey "${cur_secret_key}"
	local world_repo_path="$HOME/Desktop/share/upsider/world"
	cd "${world_repo_path}"
	git config commit.gpgsign true
}

case "$(get_cur_secret_key)" in
	"")
		generate_secret_key
		;;
	*)
		export_public_key
	 	;;
esac

