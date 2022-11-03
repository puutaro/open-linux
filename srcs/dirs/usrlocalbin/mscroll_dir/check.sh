#!/bin/bash

check_home_imwheelrc(){
	echo "##############################################"
	REWRITE="no"
	CURRENT_MSCROLL_COMMAND1="$(echo $(cat ${SETTING_FILE_PATH} | grep None | grep Up | grep Button4))"
	if [ "${REWRITE}" = "no" ]; then
		if [ -z "${CURRENT_MSCROLL_COMMAND1}" ]; then
			REWRITE="yes"
			echo "REWRITE: ${REWRITE} (CURRENT_MSCROLL_COMMAND1 not found)"
		fi
	fi

	CURRENT_MSCROLL_COMMAND2="$(echo $(cat ${SETTING_FILE_PATH} | grep None | grep Down | grep Button5))"
	if [ "${REWRITE}" = "no" ]; then
		if [ -z "${CURRENT_MSCROLL_COMMAND2}" ]; then
			REWRITE="yes"
			echo "REWRITE: ${REWRITE} (CURRENT_MSCROLL_COMMAND2 not found)"
		fi
	fi
	CURRENT_MSCROLL_COMMAND_END1_NUM=$(echo ${CURRENT_MSCROLL_COMMAND1} | awk '{print $4}')
	if [ "${REWRITE}" = "no" ]; then
		if expr "$CURRENT_MSCROLL_COMMAND_END1_NUM" : "[0-9]*$" >/dev/null 2>&1; then
			:
		else
			REWRITE="yes"
			echo "REWRITE: ${REWRITE} (CURRENT_MSCROLL_COMMAND_END1_NUM  ireguler value (${CURRENT_MSCROLL_COMMAND_END1_NUM}))"
		fi
	fi
	CURRENT_MSCROLL_COMMAND_END2_NUM=$(echo ${CURRENT_MSCROLL_COMMAND2} | awk '{print $4}')
	if [ "${REWRITE}" = "no" ]; then
		if expr "$CURRENT_MSCROLL_COMMAND_END2_NUM" : "[0-9]*$" >/dev/null 2>&1; then
			:
		else
			REWRITE="yes"
			echo "REWRITE: ${REWRITE} (CURRENT_MSCROLL_COMMAND_END2_NUM  ireguler value (${CURRENT_MSCROLL_COMMAND_END2_NUM}))"
		fi
	fi
	CURRENT_MSCROLL_COMMAND_END1=$(echo ${CURRENT_MSCROLL_COMMAND1} | awk '{print $5}')
	if [ "${REWRITE}" = "no" ]; then
		if [ -n "${CURRENT_MSCROLL_COMMAND_END1}" ]; then
			REWRITE="yes"
			echo "REWRITE: ${REWRITE} (CURRENT_MSCROLL_COMMAND_END1  ireguler value (${CURRENT_MSCROLL_COMMAND_END1}))"
		fi
	fi
	CURRENT_MSCROLL_COMMAND_END2=$(echo ${CURRENT_MSCROLL_COMMAND2} | awk '{print $5}')
	if [ "${REWRITE}" = "no" ]; then
		if [ -n "${CURRENT_MSCROLL_COMMAND_END2}" ]; then
			REWRITE="yes"
			echo "REWRITE: ${REWRITE} (CURRENT_MSCROLL_COMMAND_END2 ireguler value (${CURRENT_MSCROLL_COMMAND_END2}))"
		fi
	fi
	echo "##############################################"
	if [ "${REWRITE}" = "yes" ]; then
		echo "make imwheelrc file (above err)"
  	else
  		cat ${SETTING_FILE_PATH} > ${SETTING_FILE_PATH}.bk
	fi
}