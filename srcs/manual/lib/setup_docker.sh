#!/bin/bash

# 古いバージョンがあれば削除
for pkg in docker.io docker-doc docker-compose \
docker-compose-v2 podman-docker containerd runc; \
do sudo apt-get -y remove $pkg; done

# 依存パッケージインストール
sudo apt-get -y update
sudo apt-get -y install ca-certificates curl

# Dockerリポジトリの公開鍵をUbuntu推奨ディレクトリへ格納
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc  # おそらく不要。念のため

# Dockerリポジトリ登録
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc]  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Docker Engineのインストール
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli \
  containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $USER;