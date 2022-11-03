#!/bin/bash
KUGIRI_BAR="------------------"
DESKTOP="Desktop"
HOME_DIR="/home/xbabu"
DESKTOP_PATH="${HOME_DIR}/${DESKTOP}"
GD_DIR_PATH="${DESKTOP_PATH}/share/gd"
CPGD_DIR_PATH="${DESKTOP_PATH}/share/gdrive"

SOURCE_MY_DRIVE="${GD_DIR_PATH}/マイドライブ"
if [ ! -d "${SOURCE_MY_DRIVE}" ]; then
	mkdir -p ${SOURCE_MY_DRIVE}
fi
# TARGET_MY_DRIVE="${CPGD_DIR_PATH}/apol_mydrive/"
# if [ ! -d "${TARGET_MY_DRIVE}" ]; then
# 	mkdir -p ${TARGET_MY_DRIVE}
# fi
# echo "【逆同期されたmydriveファイル】"
# rsync -rtuv --copy-links --progress ${TARGET_MY_DRIVE}/* ${SOURCE_MY_DRIVE}/
# echo "【同期されたmydriveファイル】"
# rsync -rtuv --copy-links --progress ${SOURCE_MY_DRIVE}/* ${TARGET_MY_DRIVE}/
echo "【同期されたmydriveファイル】"
cd ${SOURCE_MY_DRIVE}
grive sync

SOURCE_SHARE_DRIVE="${GD_DIR_PATH}/共有ドライブ"
if [ ! -d "${SOURCE_SHARE_DRIVE}" ]; then
	mkdir -p ${SOURCE_SHARE_DRIVE}
fi

TARGET_SHARE_DRIVE="${CPGD_DIR_PATH}/apol_sharedrive"
if [ ! -d "${TARGET_SHARE_DRIVE}" ]; then
	mkdir -p ${TARGET_SHARE_DRIVE}
fi

TARGET_PROJECT="40_ilodoli"
echo "${KUGIRI_BAR}"
echo "【削除されたファイル】"
find ${TARGET_SHARE_DRIVE}/${TARGET_PROJECT}/ -name ".~lock.*" -type f -print0 | xargs -0 rm -v
echo "${KUGIRI_BAR}"
echo "【同期されたファイル】"
rsync -rtuv --copy-links --progress ${SOURCE_SHARE_DRIVE}/* ${TARGET_SHARE_DRIVE}/
# echo "【逆同期されたファイル】"
# rsync -rtuv --copy-links --progress ${TARGET_SHARE_DRIVE}/* ${SOURCE_SHARE_DRIVE}/
echo "${KUGIRI_BAR}"
echo "【最近2日で更新されたファイル】"
echo "●40_ilodoli"
ls "${TARGET_SHARE_DRIVE}/${TARGET_PROJECT}/"
SEARCH_FILE="$(echo "$(find ${TARGET_SHARE_DRIVE}/${TARGET_PROJECT}/ -mtime -2 -print0 | xargs -0 ls -l)")"
SEARCH_FILE="$(echo "${SEARCH_FILE}" | sed -n "/合計/q;p" | sed -n "/total/q;p")"
SEARCH_FILE_NUM=$(echo "${SEARCH_FILE}" | wc -l)
echo "${SEARCH_FILE}" | sed -n "/合計/q;p" | sed -n "/total/q;p"
echo "合計: ${SEARCH_FILE_NUM}個"
echo "${KUGIRI_BAR}_finish"