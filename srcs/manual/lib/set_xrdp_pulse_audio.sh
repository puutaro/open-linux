#!/bin/bash


sudo apt-get -y install \
	git libpulse-dev autoconf \
	m4 build-essential dpkg-dev \
	libsndfile-dev libcap-dev libtool

pulse_dir="${HOME}/dev/pulse"

mkdir -p "${pulse_dir}"
cd "${pulse_dir}"

pwd
wget https://www.freedesktop.org/software/pulseaudio/releases/pulseaudio-14.1.tar.xz
tar xf ./pulseaudio-14.1.tar.xz
cd ./pulseaudio-14.1
sudo ./bootstrap.sh
sudo ./configure
sudo make install

cd ../
git clone https://github.com/neutrinolabs/pulseaudio-module-xrdp.git
cd pulseaudio-module-xrdp
sudo ./bootstrap
sudo ./configure PULSE_DIR="${pulse_dir}/pulseaudio-14.1"
# 先にダウンロード&解凍したPulseAudioのディレクトリを指定
sudo make
cd ./src/.libs
# /home/masato/dev/pulse/pulseaudio-module-xrdp/src/.libs
sudo install -t "/var/lib/xrdp-pulseaudio-installer" -D -m 644 *.so

sudo apt purge --auto-remove pulseaudio -y

pulseaudio --kill
pulseaudio --start
