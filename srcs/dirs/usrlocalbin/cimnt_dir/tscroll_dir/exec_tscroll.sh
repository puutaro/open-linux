#!/bin/bash

DIR_NAME=$(dirname $0)
TOUCHPAD_DEVICE_NAME=$(echo "$(xinput --list --name-only | grep -i  -e touchpad -e glidepoint -e trackpad)")
SETTING_CLUMUN="Synaptics Scrolling Distance"
DEFAULT_COMMAND="xinput set-prop '${TOUCHPAD_DEVICE_NAME}' '${SETTING_CLUMUN}' -150 -150"
DEFAULT_TAPCOMMAND="xinput set-prop '${TOUCHPAD_DEVICE_NAME}' 'Synaptics Tap Action'	2, 3, 0, 0, 1, 3, 0"
DEFAULT_IMWHEEL_COMMAND='#imwheel -k &'
DEFAULT_FICTX_COMMAND='fcitx-autostart &'
USER_DIR="/home/${USER}"
STARTUP_FILE_PATH="${USER_DIR}/startup.sh"
STARTUP_FILE_BK_PATH="${STARTUP_FILE_PATH}.bk"
TOUCHPAD_DEVICE_NAME=$(xinput --list --name-only | grep -i  -e touchpad -e glidepoint)
CURRENT_TSCROLL_COMMAND=$(cat ${STARTUP_FILE_PATH} | grep xinput)

. ${DIR_NAME}/util.sh

scroll_setting_dialog () {
  while :
  do
  check_startup_scroll_value
  CURRENT_SCROLL_DISTANCE=$(echo "$(xinput list-props "${TOUCHPAD_DEVICE_NAME}" | grep "${SETTING_CLUMUN}" | awk '{print $6}')")
  CURRENT_TSCROLL_COMMAND=$(cat ${STARTUP_FILE_PATH} | grep "${TOUCHPAD_DEVICE_NAME}" | grep  xinput | grep "${SETTING_CLUMUN}" | head -n 1)
  echo "###############################################################"
	echo "スクロール量を入力して下さい(ナチュラススクロールは負数)"
	echo "現在: ${CURRENT_SCROLL_DISTANCE}"
	echo "タイプ時タッチパッド無効化: t, 終了: q"
	read ALTER_CURRENT_SCROLL_DISTANCE
	if expr "$ALTER_CURRENT_SCROLL_DISTANCE" : "-\?[0-9]\+\.\?[0-9]*$" >/dev/null 2>&1;then
		TSCROLL_COMMAND="xinput set-prop '${TOUCHPAD_DEVICE_NAME}'  'Synaptics Scrolling Distance' ${ALTER_CURRENT_SCROLL_DISTANCE} ${ALTER_CURRENT_SCROLL_DISTANCE}"
		sh -c "${TSCROLL_COMMAND}"
		sed -e "s|${CURRENT_TSCROLL_COMMAND}|${TSCROLL_COMMAND}|g" -i ${STARTUP_FILE_PATH}
		stop_imwheel_command
		echo "スクロール量設定完了"
		echo "-------------------------------------------------------------"
	else
		if [ ${ALTER_CURRENT_SCROLL_DISTANCE} = "q" ]; then 
			echo "終了します"
			exit 0
		elif [ ${ALTER_CURRENT_SCROLL_DISTANCE} = "t" ]; then 
			keybord_disable_touchpad_dialog
		else
			echo "数字を入力して下さい"
		fi
	fi
  done
}

keybord_disable_touchpad_dialog () {
  while :
  do
	CURRENT_TYPE_DISABLE_TIME=$(echo "$(ps -ef | grep syndaemon | head -n 1 |  awk '{print $10}')")
  echo "###############################################################"
  echo "タイプ時タッチパッド無効時間(秒)を入力して下さい(秒) "
	echo "現在の無効時間(秒): ${CURRENT_TYPE_DISABLE_TIME}"
	echo "設定後は一度、ログアウトします"
	echo "戻る: q"
	read TYPE_DISABLE_TIME
	if expr "$TYPE_DISABLE_TIME" : "-\?[0-9]\+\.\?[0-9]*$" >/dev/null 2>&1;then
		set -x
		syndaemon -i $TYPE_DISABLE_TIME -t -k &
		set +x
		echo "無効時間設定完了"
		pkill openbox
		echo "-------------------------------------------------------------"
	else
		if [ ${TYPE_DISABLE_TIME} = "q" ]; then 
			echo "戻ります"
			break
		else
			echo "数字を入力して下さい"
		fi
	fi
  done
}

scroll_setting_dialog