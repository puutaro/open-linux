#!/bin/bash

INI_FILE_NAME="cimnt.ini"
CI_MNT_DIR=$(dirname $0)
DEFAULT_CIMNT_INI_PATH="${CI_MNT_DIR}/${INI_FILE_NAME}"
HOME_CIMNT_INI_PATH="/home/$USER/${INI_FILE_NAME}"
REWRITE="no"
ALL_CONFIRM_TIMES=4
CURRENT_CONFIRM_TIMES=1
SETTING_USER_NAME="username"
SETTING_PASSWORD="password"
SETTING_MNT_LOCAL_DIR="mnt_local_dir"
SETTING_MNT_TARGET_DIR="mnt_target_dir"
REWRITE="no"

. ${CI_MNT_DIR}/init_setting.sh
. ${CI_MNT_DIR}/execute.sh
. ${CI_MNT_DIR}/ini_edit.sh

INIT_CURRENT_MNT_LOCAL_DIR="$(echo $(cat "${HOME_CIMNT_INI_PATH}" | grep "${SETTING_MNT_LOCAL_DIR}=" | sed "s|${SETTING_MNT_LOCAL_DIR}=||g"))"
INIT_CURRENT_MNT_LOCAL_DIR="${INIT_CURRENT_MNT_LOCAL_DIR/%?/}"
if [ -n "${INIT_CURRENT_MNT_LOCAL_DIR}" ]; then
	MOUNT_STATUS=$(echo "$(mount | grep "${INIT_CURRENT_MNT_LOCAL_DIR}")")
else
	MOUNT_STATUS="${INIT_CURRENT_MNT_LOCAL_DIR}"
fi

make_mount_err_messege(){
	echo "マウントできませんでした。"
	echo "上記の記載箇所を確認してみて下さい"
	echo "参考)"
	echo "*マウント先(ローカル/リモート)がない場合は、設定ファイルが原因"
	echo "*エラーメッセージが表示されない場合は、再度実行すると解除できるときがあります"
	echo "[Enter]で終了します"
}

make_unmount_err_messege(){
	echo "マウントを解除できませんでした。"
	echo "上記の記載箇所を確認してみて下さい"
	echo "参考)"
	echo "※エラーメッセージが表示されない場合は、再度実行すると解除できるときがあります"
	echo "[Enter]で終了します"
}


wrapper_execute_cimount(){
	INIT_CURRENT_MNT_LOCAL_DIR="$(echo $(cat "${HOME_CIMNT_INI_PATH}" | grep "${SETTING_MNT_LOCAL_DIR}=" | sed "s|${SETTING_MNT_LOCAL_DIR}=||g"))"
	INIT_CURRENT_MNT_LOCAL_DIR=$(echo "${INIT_CURRENT_MNT_LOCAL_DIR}" | sed "s|~|/home/${USER}|g")
	sudo mkdir -p "${INIT_CURRENT_MNT_LOCAL_DIR}"
	local err_massage="$(echo "$(execute_cimount "${HOME_CIMNT_INI_PATH}" 2>&1 > /dev/null)")"
	wait
	if [ -z "${err_massage}" ];then
		echo "${INIT_CURRENT_MNT_LOCAL_DIR}へのマウントが成功しました。"
		sleep 2
	else
		echo "################# エラー情報 ########################"
		echo "${err_massage}"
		echo "######################################################"
		make_mount_err_messege
		read FINISH
	fi
}

wrapper_execute_ciunmount(){
	INIT_CURRENT_MNT_LOCAL_DIR="$(echo $(cat "${HOME_CIMNT_INI_PATH}" | grep "${SETTING_MNT_LOCAL_DIR}=" | sed "s|${SETTING_MNT_LOCAL_DIR}=||g"))"
	INIT_CURRENT_MNT_LOCAL_DIR=$(echo "${INIT_CURRENT_MNT_LOCAL_DIR}" | sed "s|~|/home/${USER}|g")
	local err_massage="$(sudo umount "${INIT_CURRENT_MNT_LOCAL_DIR}" 2>&1 > /dev/null)"
	wait
	if [ -z "${err_massage}" ];then
		echo "${INIT_CURRENT_MNT_LOCAL_DIR}へのマウント解除が成功しました。"
		sleep 2
	else
		echo "################# エラー情報 ########################"
		echo "${err_massage}"
		echo "######################################################"
		make_unmount_err_messege
		read FINISH
	fi
}


REWRITE="no"
if [ -z "${MOUNT_STATUS}" ]; then
	echo "######################################################"
	echo "このままマウントとします(ENTER/e(設定ファイル編集))"
	read MOUNT_COFIRM

	if [ "${MOUNT_COFIRM}" = "e" ]; then
		ini_editting_daialog ${DEFAULT_CIMNT_INI_PATH} ${HOME_CIMNT_INI_PATH}
		echo "######################################################"
		echo "このままマウントしますか？(ENTER/e(exit))"
		read CONFIRM
		if [ "${CONFIRM}" = "e" ]; then
			exit 0
		else
			search_cimnt_ini ${DEFAULT_CIMNT_INI_PATH} ${HOME_CIMNT_INI_PATH}
			echo "INI_FILE_REWRITE: ${REWRITE} "
			if [ "${REWRITE}" = "no" ]; then
				wrapper_execute_cimount
			else
				make_mount_err_messege
				read CONFIRM
			fi
		fi
	else
		search_cimnt_ini ${DEFAULT_CIMNT_INI_PATH} ${HOME_CIMNT_INI_PATH}
		echo "INI_FILE_REWRITE: ${REWRITE} "
		if [ "${REWRITE}" = "yes" ]; then
			ini_editting_daialog ${DEFAULT_CIMNT_INI_PATH} ${HOME_CIMNT_INI_PATH}
		fi
		wrapper_execute_cimount
	fi
else 
	echo "######################################################"
	echo "このままマウントを解除します(ENTER/e(設定ファイル編集))"
	read MOUNT_COFIRM
	
	if [ "${MOUNT_COFIRM}" = "e" ]; then
		ini_editting_daialog ${DEFAULT_CIMNT_INI_PATH} ${HOME_CIMNT_INI_PATH}
		echo "######################################################"
		echo "このままマウントを解除しますか？(ENTER/e(exit))"
		read MOUNT_COFIRM
		if [ "${MOUNT_COFIRM}" = "e" ]; then
			exit 0
		else
			search_cimnt_ini ${DEFAULT_CIMNT_INI_PATH} ${HOME_CIMNT_INI_PATH}
			echo "INI_FILE_REWRITE: ${REWRITE}"
			if [ "${REWRITE}" = "no" ]; then
				wrapper_execute_ciunmount
			else
				make_unmount_err_messege
				read CONFIRM
			fi
		fi
	else
		search_cimnt_ini ${DEFAULT_CIMNT_INI_PATH} ${HOME_CIMNT_INI_PATH}
		echo "INI_FILE_REWRITE: ${REWRITE} "
		if [ "${REWRITE}" = "yes" ]; then
			ini_editting_daialog ${DEFAULT_CIMNT_INI_PATH} ${HOME_CIMNT_INI_PATH}
		fi
		wrapper_execute_ciunmount
	fi
fi