#!bin/bash
sleep 5
STARTNUM=1
if [ "${STARTNUM}" -eq "1" ]; then
  touch_device_name=$(\
      xinput --list --name-only \
        | grep -i  -e touchpad -e glidepoint -e trackpad\
  )
  log_path="${HOME}/startup_log.txt"
  echo "touch_device_name ${touch_device_name}" \
    > "${log_path}"
  update_startup_con=$(\
      awk -v touch_device_name="${touch_device_name}" \
      '{
        replace_touch_device_name = "\x27"touch_device_name"\x27"
        gsub(\
          "\x27CURRENT_TOCHPAD_DEVICE_NAME\x27",\
          replace_touch_device_name,\
          $0 \
        )
        print $0
      }' "${0}"\
  ) 
  sleep 0.2
  echo "${update_startup_con}" \
    | sed "s|^STARTNUM=1$|STARTNUM=2|g" \
    > "${0}"
  bash "${0}"
  exit 0
fi
xinput set-prop 'CURRENT_TOCHPAD_DEVICE_NAME'  'Synaptics Scrolling Distance' -150 -150
xinput set-prop 'CURRENT_TOCHPAD_DEVICE_NAME'  'Synaptics Tap Action' 2, 3, 0, 0, 1, 3, 0
xinput set-prop 'CURRENT_TOCHPAD_DEVICE_NAME' 'Synaptics Two-Finger Scrolling' 1, 1
syndaemon -i 1 -t -k &
fcitx-autostart &
numlockx off &
#imwheel -k &
/usr/bin/google-chrome-stable %U &
libinput-gestures-setup restart &
echo 1621 | sudo -S updatedb
if [ ${STARTNUM} = 2 ]; then
  # default terminal emulator gnome terminal -> x-terminal
  gsettings set org.cinnamon.desktop.default-applications.terminal exec x-terminal-emulator
  libinput-gestures-setup autostart &
fi
sed -i "s|^STARTNUM=2$|STARTNUM=3|g" "$0"
