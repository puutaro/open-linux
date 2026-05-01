#!/bin/bash

# 必要なシステムパッケージ
sudo apt update && sudo apt install ffmpeg python3-pip python3-venv -y

# 仮想環境の作成（推奨）
python3 -m venv venv
source venv/bin/activate

# 必要なライブラリのインストール
pip install faster-whisper opencv-python