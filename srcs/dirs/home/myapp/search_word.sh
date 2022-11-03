#!/bin/bash
DESKTOP="デスクトップ"
DESKTOP_PATH="${HOME}/${DESKTOP}"
SEARCH_PATH="$(find -O3 ${DESKTOP_PATH}/share/gdrive/apol_sharedrive/共有ドライブ/社外公開_M4S開発/ -type f)"
echo "${SEARCH_PATH}" | head -n 1 | tail -n -1
ROW_NUM=$(echo "${SEARCH_PATH}" | wc -l)
seed_num=0
for row in $(seq 0 ${ROW_NUM})
do
	r_path="$(echo "${SEARCH_PATH}" | head -n ${seed_num} | tail -n -1)"
	#echo "${r_path}"
	atari_path=$(lgrep "CV情報" "${r_path}")
	if [ -n "${atari_path}" ]; then
		SERARCH_RESULT[i]=$(echo "${atari_path}")
	fi
	seed_num=$(expr ${seed_num} + 1)
done
echo SERARCH_RESULT
echo ${SERARCH_RESULT[@]}

exit 0
#for echo 
#find -O3 /home/kitamura/デスクトップ/share/gdrive/apol_sharedrive/共有ドライブ/社外公開_M4S開発/ -type f  | sed 's/ /\\ /g' | xargs grep 'CV情報' -rl

searchedString="`echo "CV情報" | iconv -f EUC-JP -t UTF-16`"
env LANG=ja_JP.UTF-16 strings -f -e l * | env LANG=ja_JP.UTF-16 grep ${searchedString} -rl "${DESKTOP_PATH}/share/gdrive/apol_sharedrive/共有ドライブ/"