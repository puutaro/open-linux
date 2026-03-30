#!/bin/bash

# https://lorinta.xsrv.jp/2024/11/22/%E3%80%90ubuntu%E3%80%91linux%E3%81%A7adb%E3%82%B3%E3%83%9E%E3%83%B3%E3%83%89%E3%82%92%E4%BD%BF%E7%94%A8%E3%81%A7%E3%81%8D%E3%82%8B%E3%82%88%E3%81%86%E3%81%AB%E3%81%99%E3%82%8B%E6%96%B9%E6%B3%95/

sudo usermod -aG plugdev $LOGNAME
sudo apt-get update
sudo apt-get install -y android-sdk-platform-tools-common
sudo apt-get install -y android-tools-adb


readonly android_rules_path="/etc/udev/rules.d/51-android.rules"
cat << EOS | sudo tee "${android_rules_path}"
# /etc/udev/rules.d/android.rules
SUBSYSTEM=="usb", ATTR{idVendor}=="0482", MODE="0666", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="1004", MODE="0666", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="04e8", MODE="0666", GROUP="plugdev"

EOS
# sudo cat << EOS > "${android_rules_path}"
# # /etc/udev/rules.d/android.rules
# SUBSYSTEM=="usb", ATTR{idVendor}=="0482", MODE="0666", GROUP="plugdev"
# SUBSYSTEM=="usb", ATTR{idVendor}=="1004", MODE="0666", GROUP="plugdev"
# SUBSYSTEM=="usb", ATTR{idVendor}=="04e8", MODE="0666", GROUP="plugdev"

# EOS
sudo chmod a+r "${android_rules_path}"