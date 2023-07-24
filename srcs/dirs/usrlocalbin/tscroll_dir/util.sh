#!/bin/bash

stop_imwheel_command(){
	CURRENT_IMWHEEL_COMMAND="$(echo $(cat "${STARTUP_FILE_PATH}" | grep imwheel))"
	CURRENT_IMWHEEL_COMMAND="$(echo ${CURRENT_IMWHEEL_COMMAND} | sed -e 's|&||g')"
	PRE_CURRENT_IMWHEEL_COMMAND=$(echo $(echo ${CURRENT_IMWHEEL_COMMAND} | cut -c 1-1))
	if [ ! "${PRE_CURRENT_IMWHEEL_COMMAND}" = "#" ]; then
		if [ -n "${PRE_CURRENT_IMWHEEL_COMMAND}" ]; then
			UPDATE_IMWHEEL_COMMAND=$(echo "#${CURRENT_IMWHEEL_COMMAND}")
			sed -i "s|${CURRENT_IMWHEEL_COMMAND}|${UPDATE_IMWHEEL_COMMAND}|" "${STARTUP_FILE_PATH}"
		fi
	fi
	echo "imwheelプロセスを終了させます"
	killall imwheel
}

check_startup_scroll_value(){
	echo "########################################"
	REMAKE="no"

	if [ ! -e "${STARTUP_FILE_PATH}" ]; then
		REMAKE="cp"
	elif [ ! -s "$STARTUP_FILE_PATH" ]; then
		REMAKE="cp"
	fi

	if [ "${REMAKE}" = "cp" ]; then
		if [ ! -e "${STARTUP_FILE_BK_PATH}" ]; then
			REMAKE="cr"
		elif [ ! -s "$STARTUP_FILE_BK_PATH" ]; then
			REMAKE="cr"
		fi
	fi

	if [ "${REMAKE}" = "cp" ]; then
		echo "STARTUP.SH REMAKE: ${REMAKE} (cp startup.sh.bk (startup.sh not found))"
		cp "${STARTUP_FILE_BK_PATH}" "${STARTUP_FILE_PATH}"
		sudo chmod +x "${STARTUP_FILE_PATH}"
	elif [ "${REMAKE}" = "cr" ]; then
  		echo "STARTUP.SH REMAKE: ${REMAKE} (create startup.sh (startup.sh.bk file not found)"
  		echo '#!/bin/bash' > "${STARTUP_FILE_PATH}"
  		echo "${DEFAULT_COMMAND}" >> "${STARTUP_FILE_PATH}"
  		echo "${DEFAULT_TAPCOMMAND}" >> "${STARTUP_FILE_PATH}"
  		echo "${DEFAULT_IMWHEEL_COMMAND}" >> "${STARTUP_FILE_PATH}"
  		echo "${DEFAULT_FICTX_COMMAND}" >> "${STARTUP_FILE_PATH}"
  		sudo chown $USER:$USER -R "${STARTUP_FILE_PATH}"
  		sudo chmod 777 -R "${STARTUP_FILE_PATH}"
  	fi

  	REWRITE="no"
  	CURRENT_TSCROLL_COMMAND=$(cat ${STARTUP_FILE_PATH} | grep  xinput | grep "${TOUCHPAD_DEVICE_NAME}"| grep "${SETTING_CLUMUN}" | head -n 1)
	STARTUP_CURRENT_SCROLL_DISTANCE=$(echo ${CURRENT_TSCROLL_COMMAND} | awk '{print $10}')

	if [ -z "$CURRENT_TSCROLL_COMMAND" ]; then
	  	REWRITE="yes"
	  	echo "STARTUP.SH REWRITE: ${REWRITE} (CURRENT_TSCROLL_COMMAND: ${CURRENT_TSCROLL_COMMAND})"
	fi

  	if expr "$STARTUP_CURRENT_SCROLL_DISTANCE" : "-\?[0-9]\+\.\?[0-9]*$" >/dev/null 2>&1;then
  	:
  	else
	  	REWRITE="yes"
	  	echo "STARTUP.SH REWRITE: ${REWRITE} (CURRENT_SCROLL_DISTANCE: ${STARTUP_CURRENT_SCROLL_DISTANCE})"
  	fi

  	CURRENT_TSCROLL_COMMAND_END=$(echo ${CURRENT_TSCROLL_COMMAND} | awk '{print $11}')
  	if [ -n "$CURRENT_TSCROLL_COMMAND_END" ]; then
	  	REWRITE="yes"
	  	echo "STARTUP.SH REWRITE: ${REWRITE} (CURRENT_TSCROLL_COMMAND_END: ${CURRENT_TSCROLL_COMMAND_END})"
	fi
	echo "########################################"
	if [ "${REWRITE}" = "yes" ]; then
	  	if [ -n "${CURRENT_TSCROLL_COMMAND}" ]; then
	  		sed -i "s|${CURRENT_TSCROLL_COMMAND}|${DEFAULT_COMMAND}|g" ${STARTUP_FILE_PATH}
	  		
	  		echo "make startup.sh file (above err)"
	  	else 
	  		sed -i "$ a ${DEFAULT_COMMAND}" ${STARTUP_FILE_PATH}
	  	fi
	else
		cat ${STARTUP_FILE_PATH} > ${STARTUP_FILE_PATH}.bk
	fi
}
