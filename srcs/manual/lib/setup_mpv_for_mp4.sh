#!/bin/bash

sudo add-apt-repository -y ppa:ubuntuhandbook1/mpv   # または team-ua のPPA
sudo apt-get update && sudo apt-get install -y mpv

readonly MPV_DIR_PATH="${HOME}/.config/mpv"
readonly MPV_DIR_SCRIPT_PATH="${MPV_DIR_PATH}/scripts"
rm -f ${MPV_DIR_SCRIPT_PATH}/mpv_thumbnail_script_*.lua

# 2. 新しいフォーク版をダウンロード
mkdir -p "${MPV_DIR_SCRIPT_PATH}"
cd "${MPV_DIR_SCRIPT_PATH}"

readonly THUMNAIL_DONLOAD_PREFIX="https://github.com/marzzzello/mpv_thumbnail_script/releases/latest/download"
readonly mpv_thumbnail_script_client_osc_name="mpv_thumbnail_script_client_osc.lua"
wget \
	 --no-verbose  \
	-O "${MPV_DIR_SCRIPT_PATH}/${mpv_thumbnail_script_client_osc_name}" \
	"${THUMNAIL_DONLOAD_PREFIX}/${mpv_thumbnail_script_client_osc_name}"
readonly mpv_thumbnail_script_server="mpv_thumbnail_script_server.lua"
wget  \
	 --no-verbose  \
	-O "${MPV_DIR_SCRIPT_PATH}/${mpv_thumbnail_script_server}" \
	"${THUMNAIL_DONLOAD_PREFIX}/${mpv_thumbnail_script_server}"

cat > ${MPV_DIR_PATH}/mpv.conf << EOF
# 全画面をデフォルトに
fullscreen=yes

# ハードウェアデコード設定（CUDA問題を回避）
hwdec=no
# hwdec=auto-copy          # ← ここを auto-copy に変更
# hwdec=vaapi            # Intel/AMDならこちらも可
# hwdec=no               # どうしても不安定なら完全オフ
# hwdec=auto-safe

# 推奨設定
vo=gpu-next
# gpu-api=vulkan
gpu-api=opengl
msg-level=ffmpeg/video=no

# 重要：内置OSCを無効化（サムネイルスクリプトがOSCを置き換えるため）
osc=no

# === 再生位置をファイルごとに記憶 ===
save-position-on-quit=yes      # 終了時に位置を保存
resume-playback=yes            # 次回自動でその位置から再生

# より便利にするオプション（おすすめ）
write-filename-in-watch-later-config=yes   # ファイル名も保存（見やすくなる）
EOF
cat > ${MPV_DIR_PATH}/input.conf << EOF
# === 音量調整 ===
UP      add volume 5
DOWN    add volume -5

# === YouTube風 0〜9でパーセントジャンプ ===
0       seek 0 absolute-percent
1       seek 10 absolute-percent
2       seek 20 absolute-percent
3       seek 30 absolute-percent
4       seek 40 absolute-percent
5       seek 50 absolute-percent
6       seek 60 absolute-percent
7       seek 70 absolute-percent
8       seek 80 absolute-percent
9       seek 90 absolute-percent
EOF


readonly SCRIPT_OPTS_DIR_PATH="${MPV_DIR_PATH}/script-opts"
mkdir -p "${SCRIPT_OPTS_DIR_PATH}"
cat > ${SCRIPT_OPTS_DIR_PATH}/mpv_thumbnail_script.conf << EOF
# サムネイルを常に有効（長い動画でも）
autogenerate=yes
autogenerate_max_duration=0
thumbnail=yes

# サムネイルの見た目
thumbnail_width=280
thumbnail_height=0
vertical_offset=24

# エラーを減らす
quiet=yes
thumbnail_hwdec=no
EOF

rm -rf /tmp/mpv_thumbs_cache 