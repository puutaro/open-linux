# #ユーザー名入力画面
# confirm_username_dialog () {
#   while :
#   do
#     echo "[###USERNAME###](${ALL_QUESTION_SEED_TIMES}/$1)"
#     echo "please, type username (q:exit)"
#     read USER_NAME
#     if [ -d /home/${USER_NAME} ]; then
#       echo "is username ${USER_NAME}, ok?(y/n/q)"
#        read CONFIRM
#        case "$CONFIRM" in
#       "n" ) : ;;
#       "y" ) echo "ok, execute in username: ${USER_NAME}"
#             break ;;
#       "q" ) echo "exit"
#               exit 0 ;;
#        esac
#     elif [ ${USER_NAME} = "q" ]; then
#        echo "exit"
#        exit 0
#     else
#        echo "sorry, username not found"
#     fi
#   done
#   echo "${ALL_QUESTION_SEED_TIMES},${USER_NAME}(ユーザー名),${CONFIRM}" > ${SOURCE_DIR_PATH}/config.csv
#   ALL_QUESTION_SEED_TIMES=$((ALL_QUESTION_SEED_TIMES+1))
# }

uninstall_dialog () {
  while :
  do
    echo "[###UNINSTALL###](${ALL_QUESTION_SEED_TIMES}/$1)"
    echo "Do you wont to delete $2 ?(y/n)"
    read CONFIRM
    if [ ${CONFIRM} = "y" ]; then
      echo "ok, deleting $2" 
      break
    elif [ ${CONFIRM} = "n" ]; then
      echo "ok, no delete" 
      break
    else
      echo "sorry, input y or n"
    fi
  done
  echo "${ALL_QUESTION_SEED_TIMES},$2,${CONFIRM}" >> ${SOURCE_DIR_PATH}/config.csv
  ALL_QUESTION_SEED_TIMES=$((ALL_QUESTION_SEED_TIMES+1))
}

install_dialog () {
  while :
  do
    echo "[###INSTALL###](${ALL_QUESTION_SEED_TIMES}/$1)"
    echo "Do you want to $2 ?(y/n)"
    read CONFIRM
    if [ ${CONFIRM} = "y" ]; then
      echo "ok, installing $2" 
      break
    elif [ ${CONFIRM} = "n" ]; then
      echo "ok, no installing $2" 
      break
    else
      echo "sorry, input y or n"
    fi
  done
  echo "${ALL_QUESTION_SEED_TIMES},$2,${CONFIRM}" >> ${SOURCE_DIR_PATH}/config.csv
  ALL_QUESTION_SEED_TIMES=$((ALL_QUESTION_SEED_TIMES+1))
}


setting_dialog () {
  while :
  do
    echo "[###SETTINGS###](${ALL_QUESTION_SEED_TIMES}/$1)"
    echo "Do you want to set $2 ?(y/n)"
    read CONFIRM
    if [ ${CONFIRM} = "y" ]; then
      echo "ok, setting $2" 
      break
    elif [ ${CONFIRM} = "n" ]; then
      echo "ok, no setting $2" 
      break
    else
      echo "sorry, input y or n"
    fi
  done
  echo "${ALL_QUESTION_SEED_TIMES},$2,${CONFIRM}" >> ${SOURCE_DIR_PATH}/config.csv
  ALL_QUESTION_SEED_TIMES=$((ALL_QUESTION_SEED_TIMES+1))
}

config_confirm_dialog () {
  while :
  do
    echo ""
    echo "OK? Above configration? (y/n)"
    echo "(if n typed, proguram finished, so if you wan't retry, please run )"
    read CONFIRM
    if [ ${CONFIRM} = "y" ]; then
      echo "ok, constitute" 
      break
    elif [ ${CONFIRM} = "n" ]; then
      echo "ok, exit at onece" 
      exit 0
    else
      echo "sorry, please, type y or n"
    fi
  done
}
