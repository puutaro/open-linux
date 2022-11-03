#!/bin/bash
windowid=$(wmctrl -xl | grep google-chrome.Google-chrome -i | tail -n -1 | awk '{print $1}')
echo $windowid
sleep 0.2
xdotool windowactivate $WINDOWID | xdotool key Alt+Right
#wmctrl -i -a ${windowid} | xdotool key Alt+Right