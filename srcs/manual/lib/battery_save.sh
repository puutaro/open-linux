#!/bin.bash


sudo apt-get install -y \
	powertop tlp tlp-rdw
sudo tlp start
readonly tlp_config_path="/etc/tlp.conf"
readonly tlp_config=$(cat "${tlp_config_path}")
sleep 0.2
echo "${tlp_config}" |\
	awk '{
		gsub(/^#START_CHARGE_THRESH_BAT/, "START_CHARGE_THRESH_BAT", $0)
		gsub(/^#STOP_CHARGE_THRESH_BAT/, "STOP_CHARGE_THRESH_BAT", $0)
		print $0
	}' | sudo tee "${tlp_config_path}"
sudo systemctl restart tlp.service
