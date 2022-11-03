#!/bin/bash
x-terminal-emulator -e bash -c "bash ${HOME}/myapp/gdrive_rsync_contents.sh; echo 1621 | sudo -S init 0"