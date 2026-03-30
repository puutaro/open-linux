#!/bin/bash

sudo add-apt-repository --remove -y ppa:remmina-ppa-team/remmina-next
sudo apt update -y
sudo apt purge  -y "remmina*" "freerdp2*"
sudo apt -y autoremove
sudo snap install remmina
