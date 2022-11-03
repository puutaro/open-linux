#!/bin/bash

check_startup_imwheel_command(){
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
  	CURRENT_STARTUP_IMWHEEL_COMMAND="$(echo $(cat "${STARTUP_FILE_PATH}" | grep imwheel | grep k | tail -n 1))"
	CURRENT_STARTUP_IMWHEEL_COMMAND="$(echo ${CURRENT_STARTUP_IMWHEEL_COMMAND} | sed -e 's|&||g')"
	PRE_STARTUP_CURRENT_IMWHEEL_COMMAND=$(echo $(echo ${CURRENT_STARTUP_IMWHEEL_COMMAND} | cut -c 1-1))

	if [ "${PRE_STARTUP_CURRENT_IMWHEEL_COMMAND}" = "#" ]; then
		UPDATE_STARTUP_IMWHEEL_COMMAND=$(echo "${CURRENT_STARTUP_IMWHEEL_COMMAND}" | awk '{print substr($0, 2)}')
		echo "REWITE ${REWITE} (UPDATE_STARTUP_IMWHEEL_COMMAND: ${UPDATE_STARTUP_IMWHEEL_COMMAND})"
		sed -i "s|${CURRENT_STARTUP_IMWHEEL_COMMAND}|${UPDATE_STARTUP_IMWHEEL_COMMAND}|" "${STARTUP_FILE_PATH}"
	fi
	if [ -z "${CURRENT_STARTUP_IMWHEEL_COMMAND}" ]; then
		REWRITE="yes"
		echo "REWITE ${REWITE} (INSERT_STARTUP_IMWHEEL_COMMAND: ${INSERT_STARTUP_IMWHEEL_COMMAND})"
		sed -i '$ a imwheel -k &' "${STARTUP_FILE_PATH}"
	fi

	if [ "${REWRITE}" = "yes" ]; then
		:
	else
		cat ${STARTUP_FILE_PATH} > ${STARTUP_FILE_PATH}.bk
	fi
}
