#!/bin/bash

readonly BASH_RC_PATH="${HOME}/.bashrc"
cd "${HOME}"
# export CLOUD_SDK_INSTALL_TYPE=install
# export INSTALL_DIR="$HOME/google-cloud-sdk"
# export PATH_MODIFY=1
# export BASH_COMPLETION=1
# export USE_PYTHON_3=1
# export PROMPT_FOR_PROJECT=0
# export DISABLE_ACCOUNT_CONFIG=1
readonly gcloud_dir_path="$HOME/google-cloud-sdk"
rm -rf "${gcloud_dir_path}"
export CLOUDSDK_INSTALL_DIR=${HOME}
export CLOUDSDK_CORE_DISABLE_PROMPTS=1
curl https://sdk.cloud.google.com \
| bash
readonly bashrc_con=$(cat "${BASH_RC_PATH}")
case "$(echo "${bashrc_con}" | grep "/google-cloud-sdk/path.bash.inc")" in
	"")
cat << EOF >> "${BASH_RC_PATH}"
# The next line updates PATH for the Google Cloud SDK.
if [ -f '${HOME}/google-cloud-sdk/path.bash.inc' ]; then . '${HOME}/google-cloud-sdk/path.bash.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '${HOME}/google-cloud-sdk/completion.bash.inc' ]; then . '${HOME}/google-cloud-sdk/completion.bash.inc'; fi
EOF
	;;
esac

gcloud init
gcloud auth login
gcloud auth application-default login

# # install gcloud
# curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz
# tar -xf google-cloud-cli-linux-x86_64.tar.gz
# yes | ./google-cloud-sdk/install.sh

# install kbctrl
readonly passwd=1621
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
echo ${passwd} | sudo -S install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
sudo apt-get install -y kubectx
yes | ./google-cloud-sdk/bin/gcloud components install gke-gcloud-auth-plugin


git config --add --global url."git@github.com:".insteadOf https://github.com && \
go env -w GONOPROXY="go.upsider.dev/core,upsidr.com,github.com/upsidr/qnit" && \
go env -w GONOSUMDB="go.upsider.dev/core,upsidr.com,github.com/upsidr/qnit" && \
go env -w GOPRIVATE="go.upsider.dev/core,upsidr.com,github.com/upsidr/qnit"

# install minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64

# install kustomize
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
sudo mv kustomize /usr/local/bin/

# install spanner-cli
go install github.com/cloudspannerecosystem/spanner-cli@latest
