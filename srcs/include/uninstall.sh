#ubuntu uninstall package
#gnome系 nutilus系パッケージの削除
ubuntu_uninstall () {
  if [ $1 = "y" ]; then
    sudo apt purge --auto-remove ubuntu-desktop -y
    sudo apt-get purge --auto-remove gnome* -y
    sudo apt-get purge --auto-remove nautilus -y
    sudo apt purge --auto-remove *thunderbird* -y
    sudo apt purge --auto-remove *evolution* -y
    sudo apt purge --auto-remove *gnome-settings-daemon* -y
    sudo apt purge --auto-remove *gnome-shell* -y
    sudo apt purge --auto-remove *nautilus* -y
    sudo apt autoremove -y
    sudo apt autoclean
    #不要なフォルダの消去
    sudo rm -rf  /home/${USER_NAME}/.local/share/evolution
    sudo rm -rf  /home/${USER_NAME}/.local/share/gnome-settings-daemon
    sudo rm -rf  /home/${USER_NAME}/.local/share/gnome-shell
    sudo rm -rf /home/${USER_NAME}/.local/share/nautilus
    sudo rm -rf /home/${USER_NAME}/.config/nautilus
    sudo rm -rf /home/${USER_NAME}/.config/gnome-session
    sudo rm -rf /home/${USER_NAME}/.config/gedit
    sudo rm -rf /home/${USER_NAME}/.config/evolution
    sudo rm -rf /home/${USER_NAME}/.config/dconf
  fi
}
