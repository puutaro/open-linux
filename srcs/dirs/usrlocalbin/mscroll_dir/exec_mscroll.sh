#!/bin/bash

set -e

DEFAULT_SETTING_FILE_NAME="imwheelrc"
DEFAULT_SETTING_DIR_PATH=$(dirname $0)

TOUCHPAD_DEVICE_NAME="$(echo "$(xinput --list --name-only | grep -i  -e touchpad -e glidepoint -e trackpad)")"
SETTING_CLUMUN="Synaptics Scrolling Distance"
DEFAULT_COMMAND="xinput set-prop '${TOUCHPAD_DEVICE_NAME}' '${SETTING_CLUMUN}' -150 -150"
DEFAULT_TAPCOMMAND="xinput set-prop '${TOUCHPAD_DEVICE_NAME}' 'Synaptics Tap Action'	2, 3, 0, 0, 1, 3, 0"
DEFAULT_IMWHEEL_COMMAND='imwheel -k &'
DEFAULT_FICTX_COMMAND='fcitx-autostart &'

DEFAULT_SETTING_FILE_PATH="${DEFAULT_SETTING_DIR_PATH}/${DEFAULT_SETTING_FILE_NAME}"
SETTING_COMMAND="imwheel -k"
START_UP_SETTING_COMMAND="imwheel -k &"
SETTING_CLUMUN="Synaptics Scrolling Distance"
SETTING_FILE_NAME=".imwheelrc"
USER_DIR="/home/${USER}"
STARTUP_FILE_PATH="${USER_DIR}/startup.sh"
STARTUP_FILE_BK_PATH="${STARTUP_FILE_PATH}.bk"
HOME_SETTING_FILE_PATH="${USER_DIR}/${SETTING_FILE_NAME}"
SETTING_FILE_PATH="$(echo $(find /home/*/"${SETTING_FILE_NAME}" -name "${SETTING_FILE_NAME}" | head -n 1))"

. "${DEFAULT_SETTING_DIR_PATH}"/check.sh
. "${DEFAULT_SETTING_DIR_PATH}"/util.sh

mscroll_setting_dialog () {
  while :
  do
  check_startup_imwheel_command
  check_home_imwheelrc
  CURRENT_MSCROLL_COMMAND1=$(cat ${SETTING_FILE_PATH} | grep Up)
  CURRENT_MSCROLL_COMMAND2=$(cat ${SETTING_FILE_PATH} | grep Down)
  CURRENT_MSCROLL_DISTANCE=$(cat "${SETTING_FILE_PATH}" | grep Up | awk '{print $4}')
  echo "###############################################################"
	echo "スクロール量(+)を入力して下さい(終了: q)"
	echo "現在: ${CURRENT_MSCROLL_DISTANCE}"
	read ALTER_CURRENT_MSCROLL_DISTANCE
	if expr "$ALTER_CURRENT_MSCROLL_DISTANCE" : "[0-9]*$" >/dev/null 2>&1;then
		TSCROLL_COMMAND1="None, Up,   Button4, ${ALTER_CURRENT_MSCROLL_DISTANCE}"
		TSCROLL_COMMAND2="None, Down, Button5, ${ALTER_CURRENT_MSCROLL_DISTANCE}"
		sed -i "s|${CURRENT_MSCROLL_COMMAND1}|${TSCROLL_COMMAND1}|g" "${SETTING_FILE_PATH}"
		sed -i "s|${CURRENT_MSCROLL_COMMAND2}|${TSCROLL_COMMAND2}|g" "${SETTING_FILE_PATH}"
		sh -c "${SETTING_COMMAND}"
		echo "スクロール量設定完了"
		echo "-------------------------------------------------------------"
	else
		if [ ${ALTER_CURRENT_MSCROLL_DISTANCE} = "q" ]; then 
			echo "終了します"
			exit 0
		elif [ ${ALTER_CURRENT_MSCROLL_DISTANCE} = "t" ]; then 
			keybord_disable_touchpad_dialog
		else
			echo "正の数字を入力して下さい"
		fi
	fi
  done
}

mscroll_setting_dialog