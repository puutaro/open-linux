#!/bin/bash

# エラーが発生したら即座にスクリプトを終了
set -e

# 定数の定義
DOWNLOAD_URL="https://www.johnvansickle.com/ffmpeg/old-releases/ffmpeg-6.0.1-amd64-static.tar.xz"
TARGET_DIR="$HOME/d_pkg/ffmpeg"
TEMP_ARCHIVE="/tmp/ffmpeg-release-amd64-static.tar.xz"

echo "============================================="
echo " FFmpeg Static Build セットアップスクリプト"
echo "============================================="

# 1. ターゲットディレクトリの作成
echo "📁 ターゲットディレクトリを作成中: ${TARGET_DIR}"
mkdir -p "${TARGET_DIR}"

# 2. アーカイブのダウンロード
echo "📥 データをダウンロード中..."
curl -L "${DOWNLOAD_URL}" -o "${TEMP_ARCHIVE}"

# 3. 解凍（親ディレクトリを無視して直下に配置）
echo "📦 圧縮ファイルを解凍中..."
# --strip-components=1 で内部の「ffmpeg-xxxx-static/」フォルダを無視して中身だけを展開
tar -xf "${TEMP_ARCHIVE}" -C "${TARGET_DIR}" --strip-components=1

# 4. 一時ファイルの削除
echo "🧹 一時ファイルをクリーンアップ中..."
rm -f "${TEMP_ARCHIVE}"

# 5. 動作確認
echo "✅ 完了しました！"
echo "---------------------------------------------"
echo "設置先: ${TARGET_DIR}/ffmpeg"
echo "バージョン確認を実行します:"
"${TARGET_DIR}/ffmpeg" -version | head -n 1
echo "---------------------------------------------"