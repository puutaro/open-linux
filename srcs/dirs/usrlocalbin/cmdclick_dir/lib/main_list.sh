
IMPORT_CMDCLICK_VAL=1
#. "${SOURCE_DIR_PATH}/exec_cmdclick.sh"
import_path_input_gui="$(dirname $0)/input_gui.sh"
import_path_exec_cmdclick="$(dirname $(dirname $0))/exec_cmdclick.sh"
. "${import_path_exec_cmdclick}"

export CMDCLICK_CONF_DIR_PATH=${CMDCLICK_CONF_DIR_PATH}
# --header="### ${INDEX_TITLE_TEXT_MESSAGE} ###"  \
EXECUTE_COMMAND=""
EXEC_TERMINAL_FOCUS=""
LANG="ja_JP.UTF-8"
IFS=$'\t' 
case "${1}" in 
    "${CMDCLICK_CONF_DIR_PATH}")
        read -r -a VALUE < <(
            echo "${2}" | \
                fzf --delimiter $'\t' \
                    --layout=reverse \
                    --border  \
                    --with-nth 1 \
                    --cycle \
                    --header-lines=1 \
                    --bind "Alt-w:execute(${CMDCLICK_EDITOR_CMD} {2}/{1})" \
                    --bind "Alt-e:execute(echo \"${EDIT_CODE} {1} {2}\" > '${CMDCLICK_PASTE_SIGNAL_FILE_PATH}')+abort" \
                    --bind "Alt-a:execute(echo \"${ADD_CODE} {1} {2}\" > '${CMDCLICK_PASTE_SIGNAL_FILE_PATH}')+abort" \
                    --bind "Alt-d:execute(echo \"${DELETE_CODE} {1} {2}\" > '${CMDCLICK_PASTE_SIGNAL_FILE_PATH}')+abort" \
                    --preview 'echo $(head -100 {2}/{1} | sed '1d' | sed '1,/'CMD_VARIABLE_SECTION'/!d' | sed '/'CMD_VARIABLE_SECTION'/d')' \
                    --bind "#:preview:${CMDCLICK_EDITOR_CMD} {2}/{1}" \
                    --color 'fg:#000000,fg+:#ddeeff,bg:#f2f2f2,preview-bg:#e6ffe6,border:#ffffff'\
                    --color 'info:#00b386,hl+:#02ebc7,hl:#0750fa,header:#000000,gutter:#000000' \
                    --color 'marker:#0750fa,spinner:#0750fa,pointer:#4382f7,prompt:#000000' \
                    --preview-window top:1
            )
        ;;
    *)
        read -r -a VALUE < <(
            echo "${2}" | \
                fzf --delimiter $'\t' \
                	--layout=reverse \
                	--border  \
                	--with-nth 1 \
                	--cycle \
                	--header-lines=1 \
                	--info=inline \
                	--preview 'echo $(head -100 {2}/{1} | sed '1d' | sed 's/^#.*//' | sed "s/^[a-zA-Z0-9_-]\{1,100\}=.*//")' \
                	--bind "Alt-w:execute(${CMDCLICK_EDITOR_CMD} {2}/{1})" \
                	--bind "Alt-e:execute(echo \"${EDIT_CODE} {1} {2}\" > '${CMDCLICK_PASTE_SIGNAL_FILE_PATH}')+abort" \
                	--bind "Alt-a:execute(echo \"${ADD_CODE} {1} {2}\" > '${CMDCLICK_PASTE_SIGNAL_FILE_PATH}')+abort" \
                	--bind "Alt-d:execute(echo \"${DELETE_CODE} {1} {2}\" > '${CMDCLICK_PASTE_SIGNAL_FILE_PATH}')+abort" \
                	--bind "Alt-c:execute(echo \"${CHDIR_CODE} {1} {2}\" > '${CMDCLICK_PASTE_SIGNAL_FILE_PATH}')+abort" \
                	--bind "Alt-s:reload(export IMPORT_CMDCLICK_VAL=1 && . ${import_path_exec_cmdclick} && . ${import_path_input_gui} && export SIGNAL_CODE=${SIGNAL_CODE} && exec_inc && reload_cmd)" \
                	--bind "Alt-x:reload(export IMPORT_CMDCLICK_VAL=1 && . ${import_path_exec_cmdclick} && . ${import_path_input_gui} && export SIGNAL_CODE=${SIGNAL_CODE} && exec_dec && reload_cmd)" \
                	--bind "Alt-r:reload(export IMPORT_CMDCLICK_VAL=1 && . ${import_path_exec_cmdclick} && . ${import_path_input_gui} && export SIGNAL_CODE=${SIGNAL_CODE} && reload_cmd)" \
                	--bind "alt-v:execute(echo {2}/{1} | tr -d '\n' | xclip -selection c -i)" \
                	--color 'fg:#000000,fg+:#ddeeff,bg:#f2f2f2,preview-bg:#e6ffe6,border:#ffffff'\
                	--color 'info:#00b386,hl+:#02ebc7,hl:#0750fa,header:#000000,gutter:#000000' \
                	--color 'marker:#0750fa,spinner:#0750fa,pointer:#00b386,prompt:#000000' \
                	--preview-window top:1
            )
    ;;
esac
status_code=$?
IFS=$' \n\t' 
echo "${VALUE[0]}
${VALUE[1]}" > "${CMDCLICK_VALUE_SIGNAL_FILE_PATH}"