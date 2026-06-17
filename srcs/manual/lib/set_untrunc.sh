#!/bin/bash

set -ue
readonly D_PKG_DIR_PATH="${HOME}/d_pkg"
mkdir -p "${D_PKG_DIR_PATH}"
cd "${D_PKG_DIR_PATH}"
readonly UNTRUNC_DIR_PATH="${D_PKG_DIR_PATH}/untrunc"
rm -rf "${UNTRUNC_DIR_PATH}"
sudo apt-get install -y libavformat-dev libavcodec-dev libavutil-dev
readonly UNTRUNC_NAME="$(basename "${UNTRUNC_DIR_PATH}")"
git clone https://github.com/anthwlock/${UNTRUNC_NAME}
cd "${UNTRUNC_DIR_PATH}"
make
sudo cp ${UNTRUNC_NAME} /usr/local/bin

