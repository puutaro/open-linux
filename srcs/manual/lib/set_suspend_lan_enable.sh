#!/bin/bash

readonly driver_name=$(
	sudo lshw -c network \
	| grep driver= \
	| grep -oE "driver=[a-z]*" \
	| sed 's/driver=//'\
)
readonly USER_HOME=$(pwd | grep -oE "/home/[a-z0-9_-]*")

readonly resume_eth_path="$USER_HOME/resume-eth"

cat - << EOS > "${resume_eth_path}"
#!/bin/sh

sudo modprobe -r "${driver_name}"
sudo modprobe -i "${driver_name}"
# sudo systemctl restart network-manager
EOS
sudo chmod +x "${resume_eth_path}"

sudo sh -c 'cat << EOF > /etc/systemd/system/resume-eth.service
[Unit]
Description=Restart network-manager at resume
After=suspend.target
After=hibernate.target
After=hybrid-sleep.target

[Service]
Type=oneshot
ExecStart='${resume_eth_path}'

[Install]
WantedBy=suspend.target
WantedBy=hibernate.target
WantedBy=hybrid-sleep.target
EOF'

sudo systemctl restart network-manager
sudo systemctl status resume-eth.service
sudo systemctl enable resume-eth.service
sudo systemctl restart resume-eth.service