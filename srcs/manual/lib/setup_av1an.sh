#!/bin/bash
set -e

echo "=================================================="
echo "🚀 Av1an v0.6.0~ (最新master仕様) 全機能ビルドを開始"
echo "=================================================="

# 1. 必要なツールをOS（apt）側へ一網打尽に投入
sudo apt update
sudo apt install -y \
    build-essential cmake nasm pkg-config git \
    python3-pip python3-venv ffmpeg mkvtoolnix \
    rav1e libx265-dev libx264-dev x265
# 👈 最新版ビルドに必要な開発用ライブラリも追加


sudo apt update && sudo apt install ffmpeg python3-pip python3-venv -y
rm -rf ~/venv
# 仮想環境の作成（推奨）
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install scenedetect[opencv]


mkdir -p "$HOME/.local/bin"

# 2. 最新のソースコードを取得して「全機能有効」でコンパイル
BUILD_DIR=$(mktemp -d)
cd "$BUILD_DIR"

git clone https://github.com/master-of-zen/Av1an.git
cd Av1an

cargo install --path av1an --locked

cd "$HOME"
rm -rf "$BUILD_DIR"

# 3. パスの紐付け
ln -sf "$HOME/.cargo/bin/av1an" "$HOME/.local/bin/av1an"

echo "=================================================="
echo "🎉 v0.6.0~ 全機能有効版のビルドが完了しました！"
echo "=================================================="