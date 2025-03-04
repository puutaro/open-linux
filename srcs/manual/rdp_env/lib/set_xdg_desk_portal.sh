#!/bin/bash

### LABELING_SECTION_START
### LABELING_SECTION_END


### SETTING_SECTION_START
terminalDo=ON
openWhere=CW
terminalFocus=OFF
editExecute=ONCE
setVariableTypes="SWITCH:CB=INNER!OUT"
beforeCommand=
afterCommand=
execBeforeCtrlCmd=
execAfterCtrlCmd=
appIconPath=
scriptFileName=set_xdg_desk_portal.sh
### SETTING_SECTION_END


### CMD_VARIABLE_SECTION_START
SWITCH=OUT
### CMD_VARIABLE_SECTION_END


### Please write bellow with shell script

 
readonly SERVICE_PATH="/usr/lib/systemd/user/xdg-desktop-portal-gtk.service"
# [Service]
# --> Environment="DISPLAY=:10.0"
function switch_display_num(){
	local display_num="${2}"
	if [ -z "${DISPLAY_ENV}" ];then
		sudo \
			sed -i "$ a Environment=\"DISPLAY=${display_num}\"" \
			"${SERVICE_PATH}"
		return
	fi
	sudo \
		sed -i "s/Environment=\"DISPLAY=.*\"/Environment=\"DISPLAY=${display_num}\"/" \
			"${SERVICE_PATH}"
}
readonly CUR_SERVICE_CON=$(\
	cat "${SERVICE_PATH}"\
)
readonly DISPLAY_ENV=$(\
	echo "${CUR_SERVICE_CON}"\
	| grep -E "Environment=\"DISPLAY=.*\""
)
case "${SWITCH}" in
	"INNER")
		switch_display_num \
			"${CUR_SERVICE_CON}" \
			"10.0"
		;;
	"OUT")
		switch_display_num \
			"${CUR_SERVICE_CON}" \
			"0.0"
		;;
esac

systemctl --user restart  xdg-desktop-portal
systemctl --user status  xdg-desktop-portal
