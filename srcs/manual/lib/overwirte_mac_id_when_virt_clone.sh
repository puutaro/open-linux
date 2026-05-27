#!/bin/bash
# =============================================
# virt-managerクローン後のUbuntu 同一識別子リセットスクリプト
# 実行後、再起動してください
# =============================================

set -e

echo "=== virt-clone 同一識別子リセット開始 ==="

# 1. machine-id 完全再生成
echo "1. /etc/machine-id を再生成..."
sudo rm -f /etc/machine-id
sudo dbus-uuidgen --ensure=/etc/machine-id
sudo systemd-machine-id-setup


# 3. ホスト名を一時的に変更（任意・必要ならコメント解除）
# echo "3. ホスト名を変更（例: ubuntu-vm2）..."
# sudo hostnamectl set-hostname ubuntu-vm2
# sudo sed -i "s/127.0.1.1.*/127.0.1.1\tubuntu-vm2/" /etc/hosts

# 4. ネットワーク関連のキャッシュクリア
echo "4. ネットワークキャッシュをクリア..."
sudo rm -f /var/lib/dhcp/dhclient.*
sudo ip link set dev enp1s0 down 2>/dev/null || true   # インターフェース名は環境に合わせて
sudo ip link set dev ens3 down 2>/dev/null || true

# 5. ブラウザ関連の共通キャッシュ削除（Chrome/Firefox/Edge）
echo "5. ブラウザキャッシュ・Cookieを一括削除..."
for user in $(ls /home/); do
    if [ -d "/home/$user/.config/google-chrome" ]; then
        rm -rf "/home/$user/.config/google-chrome/Default/Cookies" \
               "/home/$user/.config/google-chrome/Default/Cache" 2>/dev/null || true
        echo "   Chromeキャッシュ削除: $user"
    fi
    if [ -d "/home/$user/.mozilla/firefox" ]; then
        rm -rf /home/$user/.mozilla/firefox/*.default-release/cookies.sqlite \
               /home/$user/.mozilla/firefox/*.default-release/cache2 2>/dev/null || true
        echo "   Firefoxキャッシュ削除: $user"
    fi
done

echo "=== リセット完了！ ==="
echo "以下のコマンドで再起動してください："
echo "sudo reboot"