#!/bin/bash

get_usr(){
	echo "${1}" \
		| awk '{
			split($0, path_array, "/")
			print path_array[3]
		}'
}
get_desktop_path(){
	local en_desktop_path="${1}/desktop"
	if [ -d "${en_desktop_path}" ];then
		echo "${en_desktop_path}"
		return
	fi
	local kana_desktop_path="${1}/デスクトップ"
	if [ -d "${kana_desktop_path}" ];then
		echo "${kana_desktop_path}"
		return
	fi
	echo "deskotp path not found"
	exit 0
}
readonly HOME_PATH="/home/$(get_usr "${0}")"
readonly DESKTOP_DIR_PATH="$(get_desktop_path "${HOME_PATH}")"
# --- 設定項目 ---
# 実行したい自作スクリプトのフルパスを指定してください
readonly TARGET_SCRIPT="${DESKTOP_DIR_PATH}/share/shell/cmdclick/full_use/vlc_play.sh"
# 右クリックメニューに表示される名前
readonly ACTION_NAME="履歴vlc shellで再生"
# 設定ファイルの名前
readonly ACTION_FILE_NAME="mp4_custom_action.nemo_action"

# --- 処理開始 ---
readonly ACTION_DIR="${HOME_PATH}/.local/share/nemo/actions"

# 1. ディレクトリの作成
if [ ! -d "$ACTION_DIR" ]; then
    echo "ディレクトリを作成中: $ACTION_DIR"
    mkdir -p "$ACTION_DIR"
fi

# 2. .nemo_action ファイルの生成
cat << EOF > "$ACTION_DIR/$ACTION_FILE_NAME"
[Nemo Action]
Active=true
Name=$ACTION_NAME
Comment=mp4ファイルに対してvlcで特別再生します。
Exec=$TARGET_SCRIPT %f --mode paste
Icon-Name=video-x-generic
Selection=s
Extensions=mp4;
Quote=double
EOF

# 3. 実行権限の付与（ターゲットのスクリプトに対して）
if [ -f "$TARGET_SCRIPT" ]; then
    chmod +x "$TARGET_SCRIPT"
    echo "完了: $TARGET_SCRIPT に実行権限を付与しました。"
else
    echo "警告: $TARGET_SCRIPT が見つかりません。パスが正しいか確認してください。"
fi

echo "成功: $ACTION_DIR/$ACTION_FILE_NAME を作成しました。"
echo "Nemoを再起動（nemo -q）すると反映されます。"