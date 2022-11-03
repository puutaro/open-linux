#!/bin/bash
#!/bin/bash
KUGIRI_BAR="------------------"
DESKTOP="Desktop"
DESKTOP_PATH="${HOME}/${DESKTOP}"
TARGET_CGDB_PATH="${DESKTOP_PATH}/share/haumi-gp/cgdrive/"
TARGET_MY_DRIVE_PATH="${TARGET_CGDB_PATH}/mydrive"
TARGET_SHARE_DRIVE_PATH="${TARGET_CGDB_PATH}/share_drive"
echo "${KUGIRI_BAR}"
echo "【削除されたファイル】"
find ${DESKTOP_PATH}/share/haumi-gp/cgdrive/share_drive/m4s/ -name ".~lock.*" -type f -print0 | xargs -0 rm -v
echo "${KUGIRI_BAR}"
echo "【同期されたファイル】"
rsync -rtuv --copy-links --progress ${DESKTOP_PATH}/share/gdrive/share_drive/* ${DESKTOP_PATH}/share/haumi-gp/cgdrive/share_drive/
echo "${KUGIRI_BAR}"
echo "【最近2日で更新されたファイル】"
SEARCH_FILE="$(echo "$(find ${DESKTOP_PATH}/share/haumi-gp/cgdrive/share_drive/m4s/ -mtime -2 -print0 | xargs -0 ls -l)")"
SEARCH_FILE="$(echo "${SEARCH_FILE}" | sed -n "/合計/q;p")"
SEARCH_FILE_NUM=$(echo "${SEARCH_FILE}" | wc -l)
echo "${SEARCH_FILE}" | sed -n "/合計/q;p"
echo "合計: ${SEARCH_FILE_NUM}個"
echo "${KUGIRI_BAR}_finish"
cat
sleep 5