#!/bin/bash

# 必要なシステムパッケージ
sudo apt update && sudo apt install ffmpeg python3-pip python3-venv -y

rm -rf ~/venv
# 仮想環境の作成（推奨）
python3 -m venv venv
source venv/bin/activate

# 必要なライブラリのインストール
pip install --upgrade pip
pip uninstall \
	-y \
	faster-whisper opencv-python torch torchaudio torchaudio
pip install faster-whisper opencv-python