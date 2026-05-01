#!/bin/bash

set -ue

sudo dpkg --add-architecture i386
sudo mkdir -pm755 /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources
sudo apt update -y
sudo apt install -y --install-recommends winehq-stable


echo "Please downlod kindle Kindle for PC 1.40.65535 and input kindle.exe path"
read -e -p ": " KINDLE_PATH

if [ ! -f "${KINDLE_PATH}" ];then
	echo "KINDLE_PATH not exist: ${KINDLE_PATH}"
	exit 1
fi

readonly APP_DIR_PATH="$HOME/.local/share/applications"
readonly KINDLE_DESKTOP_PATH="$APP_DIR_PATH/kindle.desktop"

cat <<EOF > "${KINDLE_DESKTOP_PATH}"
[Desktop Entry]
Name=Kindle for PC
Exec=wine "${KINDLE_PATH}"
Type=Application
Categories=Office;
Terminal=false
Icon=system-run
Comment=Amazon Kindle for PC on Wine
EOF

chmod +x "${KINDLE_DESKTOP_PATH}"


update-desktop-database "${APP_DIR_PATH}"
