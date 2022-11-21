#!/bin/bash

#shere直下のshell配下にopen Linuxフォルダを置く
#そして下記のコマンドを実行
# LANG=C
# sudo apt install install -y samba samba-client cifs-utils
# mkdir -p /home/${USER}/mnt/haumi
# sudo mount -t cifs -o username=haumi,password=1621,uid=1000,gid=1000 //192.168.0.4/share ~/mnt/haumi

set -e
#---------INCLUDE-------------
SOURCE_DIR_PATH=$(dirname $0)
. ${SOURCE_DIR_PATH}/include/dialog.sh
. ${SOURCE_DIR_PATH}/include/uninstall.sh
#-------------------------------------

#--------- CONFIRM -------------
ALL_QUESTION_TIMES=13
ALL_QUESTION_SEED_TIMES=1

#ユーザー名入力画面,アンインストール、インストールパッケージ確認
confirm_username_dialog ${ALL_QUESTION_TIMES}
uninstall_dialog ${ALL_QUESTION_TIMES} "Gnome and Naulilus(重いパッケージを削除)"
G_DELETE_SWICH=${CONFIRM}
setting_dialog ${ALL_QUESTION_TIMES} "no netplan settings (ネットプランの設定をしない)"
NO_NETPLAN_SETTING_CONFIRM=${CONFIRM}
setting_dialog ${ALL_QUESTION_TIMES} "auto login (openboxセッションへ自動ログインできる設定)"
AUTO_LOGIN_CONFIRM=${CONFIRM}
setting_dialog ${ALL_QUESTION_TIMES} "No Power on gedlid (蓋を閉じても起動できる設定をしない)"
POWER_ON_GET_LID_INSTALL_CONFIRM=${CONFIRM}
setting_dialog ${ALL_QUESTION_TIMES} "Wake up On Lan (LANからPCを起動できる設定)"
WAKE_UP_ON_LAN_INSTALL_CONFIRM=${CONFIRM}
install_dialog ${ALL_QUESTION_TIMES} "Printer driver (linux対応プリンタを使えるようにする)"
PRINTER_DRIVER_CONFIRM=${CONFIRM}
install_dialog ${ALL_QUESTION_TIMES} "Libre Office (linuxでも使えるオフィスツール)"
LIBRE_OFFICE_INSTALL_CONFIRM=${CONFIRM}
install_dialog ${ALL_QUESTION_TIMES} "LXD (Linux専用コンテナマネージャ)"
LXD_INSTALL_CONFIRM=${CONFIRM}
install_dialog ${ALL_QUESTION_TIMES} "Kvm and Qenu (Linux用仮想環境)"
KVM_QENU_INSTALL_CONFIRM=${CONFIRM}
install_dialog ${ALL_QUESTION_TIMES} "PlayOnLinux (windowsアプリ(kindle等)が楽しめる)"
PLAY_ON_LINUX_INSTALL_CONFIRM=${CONFIRM}
install_dialog ${ALL_QUESTION_TIMES} "Remote Desktop (リモートデスクトップ)"
REMOTE_DESKTOP_INSTALL_CONFIRM=${CONFIRM}
install_dialog ${ALL_QUESTION_TIMES} "Sublime text (開発用の軽量エディタ)"
SUBLIME_TEXT_INSTALL_CONFIRM=${CONFIRM}

#再確認画面
echo "###########################################################################"
cat ${SOURCE_DIR_PATH}/config.csv| column -s, -t
echo "###########################################################################"
config_confirm_dialog
#-------------------------------

#------------- global setting ------------------------------
SOURCE_DIR_PATH=$(echo $(cd $(dirname $0) && pwd))
SOURCE_FILES_DIR_PATH="${SOURCE_DIR_PATH}/files"
SOURCE_DIR_FOLDA_PATH="${SOURCE_DIR_PATH}/dirs"
SOURCE_HOME_PATH="${SOURCE_DIR_FOLDA_PATH}/home"
SOURCE_CONFIG_PATH="${SOURCE_DIR_FOLDA_PATH}/config"
SOURCE_FILE_MANAGER_MENU_PATH="${SOURCE_DIR_FOLDA_PATH}/file_manager_menu"
SOURCE_GROBAL_MENU_PATH="${SOURCE_DIR_FOLDA_PATH}/grobal_menu"
SOURCE_IMAGES_PATH="${SOURCE_DIR_FOLDA_PATH}/images"
SOURCE_IMAGES_LOGO_PATH="${SOURCE_IMAGES_PATH}/logo"
SOURCE_IMAGES_WALLPAPERS_PATH="${SOURCE_IMAGES_PATH}/wallpapers"
SOURCE_ICON_THEME_PATH="${SOURCE_DIR_FOLDA_PATH}/icon_theme"
SOURCE_USRLOCALBIN_PATH="${SOURCE_DIR_FOLDA_PATH}/usrlocalbin"
SOURCE_THEMES_PATH="${SOURCE_DIR_FOLDA_PATH}/themes"
SOURCE_NEMO_ACTIONS_PATH="${SOURCE_DIR_FOLDA_PATH}/usr_shr_nemo_acts"

TARGET_HOME_DIR_PATH="/home/${USER_NAME}"
TARGET_CONFIG_PATH="${TARGET_HOME_DIR_PATH}/.config"
TARGET_OPENBOX_PATH="${TARGET_CONFIG_PATH}/openbox"
TARGET_FILE_MANAGER_MENU_PATH="/usr/local/share/file-manager/actions"
TARGET_GROBAL_MENU_PATH="/usr/share/applications"
TARGET_IMAGES_LOGO_PATH="${TARGET_CONFIG_PATH}/lxpanel/default/panels"
TARGET_IMAGES_WALLPAPERS_PATH="${TARGET_CONFIG_PATH}/pcmanfm/images"
TARGET_BACKGROUNDS_PATH="/usr/share/backgrounds/"
TARGET_ICON_THEME_PATH="/usr/share/icons"
TARGET_USRLOCALBIN_PATH="/usr/local/bin"
TARGET_NETPLAN_DIR_PATH="/etc/netplan"
TARGET_NEMO_ACTIONS_PATH="/usr/share/nemo/actions"
#壁紙名取得
WALL_FILE_NAME=$(ls -l ${SOURCE_IMAGES_WALLPAPERS_PATH}  | tail -n 1 | awk '{print $9}')
#ロゴファイル名取得
LOGONAME=$(ls -l "${SOURCE_IMAGES_LOGO_PATH}"  | tail -n 1 | awk '{print $9}')
#------------ premise settings & install -------------------
#gnome系 nutilus系パッケージの削除
ubuntu_uninstall ${G_DELETE_SWICH}
#install開始
sudo apt update -y && sudo apt upgrade -y
#gnome系 nutilus系パッケージの削除
ubuntu_uninstall ${G_DELETE_SWICH}
# pv:プレビューコマンド
sudo apt install pv -y
if [ "${NO_NETPLAN_SETTING_CONFIRM}" = "n" ]; then
  #netplan settings
  net_plan_yaml="01-network_manager.yaml"
  sudo cp -rvf "${SOURCE_FILES_DIR_PATH}/${net_plan_yaml}" "${TARGET_NETPLAN_DIR_PATH}/${net_plan_yaml}"
  sudo chmod +x "${TARGET_NETPLAN_DIR_PATH}/${net_plan_yaml}"
  echo "netplan apply"
  sudo netplan apply
  echo "wait 10 seconds"
  sleep 10 | pv
fi
#ウィンドウマネージャインストール
sudo apt install lightdm -y
if [ "${NO_NETPLAN_SETTING_CONFIRM}" = "n" ]; then
  #netplan settings
  echo "netplan apply"
  sudo netplan apply
  echo "wait 10 seconds"
  sleep 10 | pv
fi
#ログイン画面マネージャインストール
sudo apt install lightdm-gtk-greeter -y

#ディレクトリ日本語化（参照バグ直し）
# sudo apt install -y xdg-user-dirs-gtk
# LANG=C xdg-user-dirs-gtk-update
sudo apt-get install -y xdg-user-dirs
LANG=C xdg-user-dirs-update --force
#ディレクトリ作成
sudo mkdir -p "${TARGET_CONFIG_PATH}"
sudo mkdir -p "${TARGET_OPENBOX_PATH}"
#---------------------------------------------------

#------------- install start -------------------
echo "install start"
#openbox GUI
#lxrandr：ディスプレイ  lxsession-logout:ログアウト menulibre:メニュ編集 lxrandr:ディスプレイ出力先
#xfce4-power-manager:電源管理 blueman:ブルートゥース
sudo apt install -y libayatana-appindicator3-1 \
	|| sudo apt install -y libappindicator3-1
sudo apt install -y openbox lxsession-logout obconf lxpanel feh menulibre lxrandr xfce4-power-manager blueman
# 入力系、画面出力系インストール
sudo apt install -y xorg 
sudo apt install -y xserver-xorg
sudo apt install -y xserver-xorg-input-evdev xserver-xorg-input-mouse
# lxappearance 外観を設定　xserver-xorg-input-evdev：これがないとキーボード入力ができない
sudo apt install -y xserver-xorg-input-synaptics

#日本語入力
sudo apt install -y --install-recommends fcitx fcitx-mozc
sudo apt install -y fcitx-config-gtk 
#xinput：入力 xinit：RDP時に初期設定で必要 seahorse:鍵とパスワードの管理 gnome-disk-utility:usbメモリ初期化
#file-roller:GUIメニューで圧縮ファイル展開 gdebi:dpkg展開インストール xrdp:remote desktop 
#pcmanfm:ファイルやデスクトップマネージャ cifs:network mount utility samba-client:samba系
#gnome-disk-utility:ディスクマウントや書き込み等
#gimp 画像編集ソフト lxpolkit:guiでroot実行するのに必要 mousepad:メモ帳 lxinput:マウスやキーボードの設定
#yad:gtk shell library gdb:cのdebug tool nkf:shift-jis等変換 jq:json扱うツール
# fd-find:high speed find  rcs:diff3,merge 
# commnt out thunar  thunar-archive-plugin
# rhythmbox : musicplayer
sudo apt install -y pcmanfm xinput xinit nano synapse alacarte easystroke curl tlp tlp-rdw powertop git seahorse gnome-disk-utility xfce4-terminal xfce4-taskmanager dex snapd imwheel gufw xorgxrdp vino obconf numlockx samba gdebi gparted cifs-utils smbclient gnome-disk-utility wget mtools gimp file-roller lxpolkit mousepad lxinput catfish yad gdb nkf zip unzip rename lxc-utils jq openssh-client netdiscover fd-find colordiff rcs rhythmbox
# install gh command
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null && sudo apt update && sudo apt install -y gh
# synblic link for fd
if [ ! -e "/usr/local/bin/fd" ]; then sudo ln -s $(which fdfind) /usr/local/bin/fd ;fi
# fzf install
if [ ! -e "${TARGET_HOME_DIR_PATH}/.fzf" ];then
  git clone https://github.com/junegunn/fzf.git "${TARGET_HOME_DIR_PATH}/.fzf" && yes | "${TARGET_HOME_DIR_PATH}/.fzf/install"
fi
exist_fzf_source_cmd=$(\
  cat "${TARGET_HOME_DIR_PATH}/.bashrc" \
  | grep '\[ -f ~/.fzf.bash \] && source ~/.fzf.bash' \
  || e=$? \
)
case "${exist_fzf_source_cmd}" in 
  "")
    echo "[ -f ~/.fzf.bash ] && source ~/.fzf.bash" >> "${TARGET_HOME_DIR_PATH}/.bashrc"
;;esac
unset -v exist_fzf_source_cmd
# rga install (super grep made rust)
sudo apt install ripgrep pandoc poppler-utils ffmpeg -y
wget -O - 'https://github.com/phiresky/ripgrep-all/releases/download/v0.9.6/ripgrep_all-v0.9.6-x86_64-unknown-linux-musl.tar.gz' | tar zxvf - && sudo mv ripgrep_all-v0.9.6-x86_64-unknown-linux-musl/rga* /usr/local/bin
# xrdp pulseausio bouild
sudo apt install -y git libpulse-dev autoconf m4 build-essential dpkg-dev libsndfile-dev libcap-dev libtool
#user group gui edit
sudo apt install -y gnome-system-tools
# tumpler サムネイルアプリ（シャットダウンとかが早くなる、ibusもそれ系だけど、日本語入力があれになりそうなので、あとで）
#lxapperance:外観の設定 lxhotkey-dev:ホットキーの設定
sudo apt install -y lxappearance lxhotkey-dev tumbler
# mtools:Distroshare Ubuntu Imagerでiso作成に必要 ubiquity ubiquity-frontend-gtk:gui installer
#sudo apt-get install -y ubiquity ubiquity-frontend-gtk
#mintグリーンアイコンインストール
cd "${TARGET_HOME_DIR_PATH}"
wget http://packages.linuxmint.com/pool/main/m/mint-y-icons/mint-y-icons_1.3.4_all.deb
# sudo cp -rvf "${SOURCE_THEMES_PATH}/mint-y-icons_1.3.4_all.deb" "${TARGET_HOME_DIR_PATH}/"
sudo dpkg -i mint-y-icons_1.3.4_all.deb
#chrome install
google_list_how="$(echo "$(cat /etc/apt/sources.list.d/google.list | grep "deb http://dl.google.com/linux/chrome/deb/ stable main")")"
if [ -z "${google_list_how}" ]; then
  sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' && sudo wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
  sudo apt update -y && sudo apt-get install google-chrome-stable -y
fi
# cmdclick install
if [ ! -e "${TARGET_HOME_DIR_PATH}/.cmdclick" ];then
  git clone "https://github.com/kitamura-take/cmdclick.git" "${TARGET_HOME_DIR_PATH}/.cmdclick"
fi
sudo bash "${TARGET_HOME_DIR_PATH}/.cmdclick/linux/install/installer.sh"
# difbk install
if [ ! -e "${TARGET_HOME_DIR_PATH}/.difbk" ];then
  git clone https://github.com/kitamura-take/difbk.git "${TARGET_HOME_DIR_PATH}/.difbk"
fi
sudo bash "${TARGET_HOME_DIR_PATH}/.difbk/install/install.sh" "l"
# openvpn install
sudo apt-get install openvpn -y && sudo apt-get install network-manager-openvpn -y && sudo apt-get install network-manager-openvpn-gnome -y
sudo apt-add-repository -y ppa:remmina-ppa-team/remmina-next
sudo apt-get update -y
# remmina install
sudo apt-get -y install remmina remmina-plugin-rdp
sudo apt-get install -y apt-transport-https ca-certificates software-properties-common
sudo powertop --auto-tune && sudo  -S tlp start
#libinput gesture install
LIB_MAKE_DIR="${TARGET_HOME_DIR_PATH}/libinput-gestures/"
sudo usermod -aG input $USER_NAME && sudo apt-get install xdotool xclip wmctrl libinput-tools -y
mkdir -p ${LIB_MAKE_DIR}
if [ $(ls ${LIB_MAKE_DIR} -l | wc -l) -eq 1 ]; then
  git clone http://github.com/bulletmark/libinput-gestures ${LIB_MAKE_DIR}
  cd ${LIB_MAKE_DIR}  && sudo ./libinput-gestures-setup install
  cd "${TARGET_HOME_DIR_PATH}"
fi
#shutter install
how_version_2204_plus=$(\
	cat /etc/os-release \
	| awk '($0 ~ "VERSION_ID"){
		gsub(".*=|\\.|\x22", "", $0)
		if($0 >= 2204) print $0
	}' \
)
case "${how_version_2204_plus}" in 
 "") 
 	sudo add-apt-repository -y ppa:linuxuprising/shutter
	sudo apt-get update -y
;;esac
sudo apt install -y shutter

#gdrive mount install
sudo add-apt-repository -y ppa:alessandro-strada/ppa
sudo apt-get update -y
sudo apt-get install -y google-drive-ocamlfuse
#-------------install end--------------------

if [ ${REPEAT_USE} = 2 ]; then
  echo "after seconds times, please copy and paste settings section"
  exit 0
fi
#------------ setting start -------------------
#クラッシュレポート無効化
sudo service apport stop
sudo sed -i 's|enabled=1|enabled=0|g' /etc/default/apport
#電源すぐにシャットダウンできるように
sudo sed -i 's/#DefaultTimeoutStopSec=90s/DefaultTimeoutStopSec=10s/g' /etc/systemd/system.conf
#### openbox settings
mkdir -p "${TARGET_OPENBOX_PATH}"
#rc.xml 上書き
sudo cp -rvf "${SOURCE_FILES_DIR_PATH}/rc.xml" "${TARGET_OPENBOX_PATH}/rc.xml"
# autostart
autostart="autostart"
sudo cp -rvf "${SOURCE_FILES_DIR_PATH}/${autostart}" "${TARGET_OPENBOX_PATH}/"
sudo sed -i "s|CURRENT_USER_NAME|${USER_NAME}|g" "${TARGET_OPENBOX_PATH}/${autostart}"
sudo chown ${USER_NAME}:${USER_NAME} -R "${TARGET_OPENBOX_PATH}/${autostart}"
sudo chmod 777 -R "${TARGET_OPENBOX_PATH}/${autostart}"
#usr/share直下へコピ
usrlocalbin_dir="/usr/local/bin"
sudo cp -arvf ${SOURCE_USRLOCALBIN_PATH}/* "${usrlocalbin_dir}/"
sudo chmod +x -R ${usrlocalbin_dir}/*
#/usr/share/fontsへコピー
fonts_dir_path="/usr/share/fonts/"
sudo cp -arv "${SOURCE_HOME_PATH}/.fonts/." "${fonts_dir_path}/"
sudo chmod +x -R "${fonts_dir_path}"
#home直下コピー
sudo cp -arvf "${SOURCE_HOME_PATH}/." "${TARGET_HOME_DIR_PATH}/"
cd "${TARGET_HOME_DIR_PATH}"
#pcmanfm double click interval in lxapperance
sudo chown ${USER_NAME}:${USER_NAME} -R "${TARGET_HOME_DIR_PATH}/.gtkrc-2.0"
sudo chmod 777 -R "${TARGET_HOME_DIR_PATH}/.gtkrc-2.0"
#.fonts setting
sudo chown ${USER_NAME}:${USER_NAME} -R "${TARGET_HOME_DIR_PATH}/.fonts"
sudo chmod 777 -R "${TARGET_HOME_DIR_PATH}/.fonts"
#imwheel settings
sudo chown ${USER_NAME}:${USER_NAME} -R "${TARGET_HOME_DIR_PATH}/.imwheelrc"
sudo chmod 777 -R "${TARGET_HOME_DIR_PATH}/.imwheelrc"
imwheel -k
# startupスクリプト
TOUCHPAD_DEVICE_NAME="$(echo $(xinput --list --name-only | grep -i  -e touchpad -e glidepoint -e trackpad))"
if [ -n "${TOUCHPAD_DEVICE_NAME}" ]; then
  sudo sed -i "s|CURRENT_TOCHPAD_DEVICE_NAME|${TOUCHPAD_DEVICE_NAME}|g" "${TARGET_HOME_DIR_PATH}/startup.sh"
fi
sudo chown ${USER_NAME}:${USER_NAME} -R "${TARGET_HOME_DIR_PATH}/startup.sh"
sudo chmod 777 -R "${TARGET_HOME_DIR_PATH}/startup.sh"
#ディスプレイ解像度設定
DISPLAY_RESOLUTION="$(echo $(xrandr | head -n 3 | tail -n -1 | awk '{print $1}'))"
if [ -n "${DISPLAY_RESOLUTION}" ]; then
  sudo sed -i "s|CURRENT_DISPLAY_RESOLUTION|${DISPLAY_RESOLUTION}|g" "${TARGET_OPENBOX_PATH}/rc.xml"
fi
sudo sed -i "s|CURRENT_USER_NAME|${USER_NAME}|g" "${TARGET_OPENBOX_PATH}/rc.xml"
sudo chown ${USER_NAME}:${USER_NAME} -R "${TARGET_OPENBOX_PATH}/rc.xml"
sudo chmod 777 -R "${TARGET_OPENBOX_PATH}/rc.xml"
#.config直下コピー
sudo cp -arvf "${SOURCE_CONFIG_PATH}/." "${TARGET_CONFIG_PATH}/"
#権限委譲
sudo chown ${USER_NAME}:${USER_NAME} -R "${TARGET_CONFIG_PATH}"
sudo chmod 777 -R "${TARGET_CONFIG_PATH}"
#thunar rightclick menu
thunar_right_click_menu_file="uca.xml"
TARGET_THUNAR_PATH="${TARGET_CONFIG_PATH}/Thunar"
sudo chown ${USER_NAME}:${USER_NAME} -R "${TARGET_THUNAR_PATH}/uca.xml"
sudo chmod 777 -R "${TARGET_THUNAR_PATH}/uca.xml"
#lxpanel設定
sudo mkdir -p ${TARGET_IMAGES_LOGO_PATH}
sudo cp -rvf "${SOURCE_FILES_DIR_PATH}/panel" "${TARGET_IMAGES_LOGO_PATH}/panel"
sudo cp -rvf "${SOURCE_IMAGES_LOGO_PATH}/${LOGONAME}" "${TARGET_IMAGES_LOGO_PATH}/"
sudo sed -i "s|CURRENT_LOGO_PATH|${TARGET_IMAGES_LOGO_PATH}/${LOGONAME}|g" "${TARGET_IMAGES_LOGO_PATH}/panel"
sudo cp -rvf "${SOURCE_FILES_DIR_PATH}/config" "${TARGET_CONFIG_PATH}/lxpanel/default/"
#壁紙
sudo cp -rvf "${SOURCE_IMAGES_WALLPAPERS_PATH}/${WALL_FILE_NAME}" "${TARGET_IMAGES_WALLPAPERS_PATH}/"
#pcmanfm設定（フォント、壁紙）
sudo sed -i "s|CURRENT_WALL_PAPER_PATH|${TARGET_IMAGES_WALLPAPERS_PATH}/${WALL_FILE_NAME}|g" "${TARGET_CONFIG_PATH}/pcmanfm/default/desktop-items-0.conf"
## lightdm settings
lightdm_dir_path="/etc/lightdm"
lightdm_conf="lightdm.conf"
sudo cp -rvf "${SOURCE_FILES_DIR_PATH}/lightdm.conf" "${lightdm_dir_path}/"
sudo sed -i "s|CURRENT_USER_NAME|${USER_NAME}|g" "${lightdm_dir_path}/${lightdm_conf}"
sudo chmod +x "${lightdm_dir_path}/${lightdm_conf}"
#ログイン画面壁紙設定
lightdm_greeter_conf="lightdm-gtk-greeter.conf"
sudo mkdir -p ${TARGET_BACKGROUNDS_PATH}
sudo cp -rvf "${SOURCE_IMAGES_WALLPAPERS_PATH}/${WALL_FILE_NAME}" "${TARGET_BACKGROUNDS_PATH}/"
sudo chmod +x "${TARGET_BACKGROUNDS_PATH}/${WALL_FILE_NAME}"
sudo cp -rvf "${SOURCE_FILES_DIR_PATH}/${lightdm_greeter_conf}" "${lightdm_dir_path}/${lightdm_greeter_conf}"
sudo chmod +x "${lightdm_dir_path}/${lightdm_greeter_conf}"
sudo sed -i "52i background = ${TARGET_BACKGROUNDS_PATH}/${WALL_FILE_NAME}" "${lightdm_dir_path}/${lightdm_greeter_conf}"
## pcmanfm right click menu
sudo mkdir -p ${TARGET_FILE_MANAGER_MENU_PATH}
sudo cp -rvf ${SOURCE_FILE_MANAGER_MENU_PATH}/* "${TARGET_FILE_MANAGER_MENU_PATH}/"
sudo chmod +x -R ${TARGET_FILE_MANAGER_MENU_PATH}
#startmenu pcmanfm(root)
sudo cp -rvf ${SOURCE_GROBAL_MENU_PATH}/* "${TARGET_GROBAL_MENU_PATH}/"
sudo chown ${USER_NAME}:${USER_NAME} -R "${TARGET_GROBAL_MENU_PATH}"
sudo chmod 777 -R "${TARGET_GROBAL_MENU_PATH}"
#マウスカーソルインストール
echo -------icon_theme_copy
sudo cp -arvf "${SOURCE_ICON_THEME_PATH}/." "${TARGET_ICON_THEME_PATH}/"
echo icon_theme_copy_end
cd "${TARGET_HOME_DIR_PATH}"
echo cd
sudo chown root:root -R "${TARGET_ICON_THEME_PATH}"
echo chown
sudo chmod 777 -R "${TARGET_ICON_THEME_PATH}"
echo chmod
echo -----front_terminal_start
# ターミナル起動時に最前面に出るように設定
google_list_how="$(echo "$(cat ${TARGET_HOME_DIR_PATH}/.bashrc | grep 'xdotool windowactivate $WINDOWID')")"
if [ -z "${google_list_how}" ]; then
  sudo sed -i '$ a xdotool windowactivate $WINDOWID' "${TARGET_HOME_DIR_PATH}/.bashrc"
fi
echo -----front_terminal_end
# nemo actions setting
echo "----nemo file manager setting_start"
sudo mkdir -p "${TARGET_NEMO_ACTIONS_PATH}"
sudo cp -arvf "${SOURCE_NEMO_ACTIONS_PATH}"/* "${TARGET_NEMO_ACTIONS_PATH}"/
sudo chmod +x -R "${TARGET_NEMO_ACTIONS_PATH}"
nemo_gschrma_xml_name="org.nemo.gschema.xml"
soruce_nemo_gschrma_xml_path="${SOURCE_FILES_DIR_PATH}/${nemo_gschrma_xml_name}"
target_nemo_gschrma_xml_path="/usr/share/glib-2.0/schemas/${nemo_gschrma_xml_name}"
sudo cp -arvf "${soruce_nemo_gschrma_xml_path}" "${target_nemo_gschrma_xml_path}"
sudo chmod +x -R "${target_nemo_gschrma_xml_path}"
echo "----nemo file manager setting_end"
# nemo istall (file manager)
# nemo file-manager by nautilus folk(light weight)
sudo apt install -y nemo
sudo xdg-mime default nemo.desktop inode/directory application/x-gnome-saved-search
sudo gsettings set org.gnome.desktop.background show-desktop-icons false
sudo gsettings set org.nemo.desktop show-desktop-icons true
echo -----samba_settings_start
## samaba settings
#samba共有ディレクトリ作成
MK_SHARE_DIR=0
SHARE_DIR_NAME="/home/${USER_NAME}/Desktop/share"
echo share_dire_check_start
if [ -d /home/${USER_NAME}/デスクトップ ]; then
  SHARE_DIR_NAME="/home/${USER_NAME}/デスクトップ/share"
  echo "share_dir: ${SHARE_DIR_NAME}"
  mkdir -p ${SHARE_DIR_NAME}
  MK_SHARE_DIR=1
  echo ja_desktop
elif [ -d /home/${USER_NAME}/Desktop ]; then
  SHARE_DIR_NAME="/home/${USER_NAME}/Desktop/share"
  echo "share_dir: ${SHARE_DIR_NAME}"
  mkdir -p ${SHARE_DIR_NAME}
  MK_SHARE_DIR=1
  echo en_desktop
fi
echo share_dire_check_end
echo share_dire_make_start
if [ ${MK_SHARE_DIR} -eq 0 ]; then
  mkdir -p ${SHARE_DIR_NAME}
  echo mk_share_dir
fi
echo share_dire_make_end
echo "share_dir: ${SHARE_DIR_NAME}"
share_dir_blank=$(ls | wc -l)
if [ ${share_dir_blank} -eq 0 ]; then
  sudo chown ${USER_NAME}:${USER_NAME} -R ${SHARE_DIR_NAME}
  echo chmod
  sudo chmod 777 -R ${SHARE_DIR_NAME}
elif [ ${share_dir_blank} -ge 1 ]; then
  sudo chown ${USER_NAME}:${USER_NAME} ${SHARE_DIR_NAME}
  echo chmod
  sudo chmod 777 ${SHARE_DIR_NAME}
fi
echo check_charset_smb_cf_start
samba_charset_how=$(echo "$(cat /etc/samba/smb.conf | grep "unix charset = UTF-8")")
echo v_in
if [  -z "${samba_charset_how}" ]; then
  sudo sed -i "25i\ \   dos charset = CP932\n   unix charset = UTF-8\n" /etc/samba/smb.conf
fi
echo check_charset_smb_cf_end
echo check_share_dir_smb_cf_start
samba_share_dir_how="$(echo $(cat /etc/samba/smb.conf | grep "${SHARE_DIR_NAME}"))"
echo v_in
if [ -z "${samba_share_dir_how}" ]; then
  sudo cat "${SOURCE_FILES_DIR_PATH}/smb.conf" >>  /etc/samba/smb.conf
  sudo sed -i "s|CURRENT_SHARE_DIR_NAME|${SHARE_DIR_NAME}|g" /etc/samba/smb.conf
  sudo systemctl restart smbd nmbd
  sudo systemctl enable smbd nmbd
fi
echo check_share_dir_smb_cf_end
echo -----samba_settings_end
#------------- setting end --------------------

#------------- option --------------------------
#autoloin off
lightdm_conf_path="/etc/lightdm/lightdm.conf"
if [ "${AUTO_LOGIN_CONFIRM}" = "n" ]; then
  sudo sed -e "s|user-session=openbox|#user-session=openbox|g" -i ${lightdm_conf_path}
  sudo sed -e "s|autologin-guest=false|#autologin-guest=false|g" -i ${lightdm_conf_path}
  sudo sed -e "s|autologin-user=${USER_NAME}|#autologin-user=${USER_NAME}|g" -i ${lightdm_conf_path}
  sudo sed -e "s|autologin-user-timeout=0|#autologin-user-timeout=0|g" -i ${lightdm_conf_path}
fi
#printer driver install
if [ "${PRINTER_DRIVER_CONFIRM}" = "y" ]; then
    sudo apt install -y system-config-printer-gnome \
    	|| sudo apt install -y system-config-printer system-config-printer-common 
    sudo apt install -y system-config-printer-udev smbclient \
    cups cups-pk-helper cups-bsd cups-ppdc printer-driver-cups-pdf cups-browsed \
    foomatic-db-compressed-ppds \
    printer-driver-gutenprint \
    printer-driver-foo2zjs \
    printer-driver-pnm2ppa \
    hplip printer-driver-hpcups printer-driver-hpijs \
    printer-driver-min12xxw \
    printer-driver-c2esp \
    printer-driver-ptouch \
    printer-driver-pxljr \
    printer-driver-sag-gdi \
    printer-driver-splix \
    openprinting-ppds
fi
#libre office install
if [ "${LIBRE_OFFICE_INSTALL_CONFIRM}" = "y" ]; then
    sudo apt install -y libreoffice-math libreoffice-writer libreoffice-impress libreoffice-calc libreoffice-draw libreoffice-l10n-ru libreoffice-help-ru libreoffice-gtk3 libreoffice-style-breeze libreoffice-style-sifr libreoffice-style-colibre libreoffice-pdfimport aspell-ru
fi
# lxd install
if [ "${LXD_INSTALL_CONFIRM}" = "y" ]; then
  sudo apt install -y snapd
  sudo snap install lxd
  sudo gpasswd -a ${USER_NAME} lxd
fi
#kvm qenu install
if [ "${KVM_QENU_INSTALL_CONFIRM}" = "y" ]; then
  sudo apt install libxcb-xtest0 -y && sudo apt install libegl1-mesa -y && sudo apt install libgl1-mesa-glx -y
  sudo apt install qemu-kvm qemu-utils libvirt-daemon-system libvirt-clients bridge-utils virt-manager gir1.2-spiceclientgtk-3.0 -y
  sudo apt install -y qemu
  sudo adduser ${USER_NAME} libvirt
  sudo adduser ${USER_NAME} kvm
fi
# wine playonlinux install
if [ "${PLAY_ON_LINUX_INSTALL_CONFIRM}" = "y" ]; then
  sudo apt install dnsmasq -y
  sudo dpkg --add-architecture i386
  sudo apt update -y
  sudo apt install wine wine64 wine32 winbind winetricks -y
  sudo apt install playonlinux -y
fi
#リモートデスクトップ設定
if [ "${REMOTE_DESKTOP_INSTALL_CONFIRM}" = "y" ]; then
  sudo apt install -y xrdp
  xrdp_dir_path="/etc/xrdp"
  exist_xrdp_dir=$(\
    test -d "${xrdp_dir_path}" \
      && echo "ari" \
      || e=$?
  )
  test -z "${exist_xrdp_dir}" \
    && mkdir -p "${exist_xrdp_dir}" \
    || e=$?
  set_profile_path="${TARGET_HOME_DIR_PATH}/.profile"
  xrdp_profile_kill_how="$(echo $(cat "${set_profile_path}" | grep "pkill openbox" || e=$?))"
  if [ -z "${xrdp_profile_kill_how}" ]; then
    profile_insert_row=11
    if [ ! -e "${set_profile_path}" ]; then
        profile_insert_row=1
        cat /dev/null > "${set_profile_path}"
        sudo chown ${USER_NAME}:${USER_NAME} -R "${set_profile_path}"
        sudo chmod 777 -R "${set_profile_path}"
    fi
    sudo sed -i "$ a pkill openbox" "${set_profile_path}"
  fi
  rdp_ini_file_path="${xrdp_dir_path}/xrdp.ini"
  sudo sed -e 's/^new_cursors=true/new_cursors=false/g' -i "${rdp_ini_file_path}"
  rdp_start_wm_file="${xrdp_dir_path}/startwm.sh"
  rdp_exec_op_how="$(echo "$(cat "${rdp_start_wm_file}" | grep "exec openbox-session" || e=$?)")"
  if [ -z "${rdp_exec_op_how}" ]; then
    start_wm_row="$(cat "${rdp_start_wm_file}" | grep -n "/etc/X11/Xsession" | head -1 | grep -oE "^[0-9]{1,4}" || e=$?)"
    sudo sed -i "${start_wm_row}i pkill openbox" "${rdp_start_wm_file}"
    start_wm_row="$(( ${start_wm_row} + 1 ))"
    sudo sed -i "${start_wm_row}i export GTK_IM_MODULE=fcitx" "${rdp_start_wm_file}"
    start_wm_row="$(( ${start_wm_row} + 1 ))"
    sudo sed -i "${start_wm_row}i export QT_IM_MODULE=fcitx" "${rdp_start_wm_file}"
    start_wm_row="$(( ${start_wm_row} + 1 ))"
    sudo sed -i "${start_wm_row}i export XMODIFIERS=\"@im=fcitx\"" "${rdp_start_wm_file}"
    start_wm_row="$(( ${start_wm_row} + 1 ))"
    sudo sed -i "${start_wm_row}i export DefaultIMModule=fcitx" "${rdp_start_wm_file}"
    start_wm_row="$(( ${start_wm_row} + 1 ))"
    sudo sed -i "${start_wm_row}i fcitx" "${rdp_start_wm_file}"
    start_wm_row="$(( ${start_wm_row} + 1 ))"
    sudo sed -i "${start_wm_row}i unset DBUS_SESSION_BUS_ADDRESS" "${rdp_start_wm_file}"
    start_wm_row="$(( ${start_wm_row} + 1 ))"
    sudo sed -i "${start_wm_row}i exec openbox-session"  "${rdp_start_wm_file}"
    sudo systemctl restart xrdp
  fi
fi
## sublime install & settings
sublime_user_dir_path="sublime-text/Packages/User"
sublime_preferece_file_name="Preferences.sublime-settings"
sublime_key_map_file_name='Default (Linux).sublime-keymap'
if [ "${SUBLIME_TEXT_INSTALL_CONFIRM}" = "y" ]; then
  wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
  echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sucblime-text.list
  sudo apt update -y && sudo apt install sublime-text -y
  sudo mkdir -p "${TARGET_CONFIG_PATH}/${sublime_user_dir_path}"
  sudo cp -rvf "${SOURCE_FILES_DIR_PATH}/${sublime_preferece_file_name}" "${TARGET_CONFIG_PATH}/${sublime_user_dir_path}/"
  sudo chown ${USER_NAME}:${USER_NAME} -R "${TARGET_CONFIG_PATH}/${sublime_user_dir_path}/${sublime_preferece_file_name}"
  sudo chmod 777 -R "${TARGET_CONFIG_PATH}/${sublime_user_dir_path}/${sublime_preferece_file_name}"
  sudo cp -rvf "${SOURCE_FILES_DIR_PATH}/${sublime_key_map_file_name}" "${TARGET_CONFIG_PATH}/${sublime_user_dir_path}/"
  sudo chown ${USER_NAME}:${USER_NAME} -R "${TARGET_CONFIG_PATH}/${sublime_user_dir_path}/${sublime_key_map_file_name}"
  sudo chmod 777 -R "${TARGET_CONFIG_PATH}/${sublime_user_dir_path}/${sublime_key_map_file_name}"
fi
#蓋を閉じても起動できる
if [ "${POWER_ON_GET_LID_INSTALL_CONFIRM}" = "n" ]; then
  sudo sed -i "25i HandleLidSwitch=ignore" /etc/systemd/logind.conf
fi
## wakeupon settiings
#デバイス名取得
LAN_DEVICE="$(echo $(ip a | grep "2: enp" | tail -n -2 | awk '{print $2}'))"
LAN_DEVICE=$(echo ${LAN_DEVICE} | sed -e 's|:$||g')
initd_dir_path="/etc/init.d"
if [ "${WAKE_UP_ON_LAN_INSTALL_CONFIRM}" = "y" ] && [ -n "${LAN_DEVICE}" ]; then
  sudo cp -rvf "${SOURCE_FILES_DIR_PATH}/wakeonlan" ${initd_dir_path}
  sudo sed -i "s|CURRENT_LAN_DEVICE_NAME|${LAN_DEVICE}|g" "${initd_dir_path}/wakeonlan"
  sudo chmod +x "${initd_dir_path}/wakeonlan"
  sudo update-rc.d -f wakeonlan defaults
  sudo cp -rvf "${SOURCE_FILES_DIR_PATH}/wolg" /home/
  sudo sed -i "s|CURRENT_LAN_DEVICE_NAME|${LAN_DEVICE}|g" /home/wolg
  sudo chmod +x /home/wolg
  sudo cp -rvf "${SOURCE_FILES_DIR_PATH}/wolg.service" /etc/systemd/system/
  sudo systemctl daemon-reload
  sudo systemctl enable wolg.service
  sudo systemctl start wolg.service
fi
#----------------------------------------------

#------------ chwon and chmod ------------------------------
#権限委譲
sudo chown ${USER_NAME}:${USER_NAME} -R "${TARGET_CONFIG_PATH}"
sudo chmod 777 -R "${TARGET_CONFIG_PATH}"
#----------------------------------------------

#-------------delete no use services-------------------
#不要なプログラムの除去
# if [ ${G_DELETE_SWICH} = "y" ]; then
#   sudo apt purge --auto-remove gnome-control-center gedit activity-log-manager xterm -y
#   #不要なサービスの停止
#   sudo systemctl stop   accounts-daemon
#   sudo systemctl disable   accounts-daemon
# fi
#-------------delete no use services end--------------------

#--------only new netplan apply----------------------------
if [ "${NO_NETPLAN_SETTING_CONFIRM}" = "n" ]; then
  sudo rm ${TARGET_NETPLAN_DIR_PATH}/*.yaml
  net_plan_yaml="01-network_manager.yaml"
  sudo cp -rvf "${SOURCE_FILES_DIR_PATH}/${net_plan_yaml}" "${TARGET_NETPLAN_DIR_PATH}/${net_plan_yaml}"
  sudo chmod +x "${TARGET_NETPLAN_DIR_PATH}/${net_plan_yaml}"
  echo "netplan apply"
  sudo netplan apply
  echo "wait 10 seconds"
  sleep 10 | pv
fi
#---------------------------------------------------

#----- reboot -------------------------------------
echo "Will reboot soon"
sleep 5 | pv
reboot
#----- reboot -------------------------------------
