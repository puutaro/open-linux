#!/bin/bash

cd "${HOME}"
install gcloud
curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz
tar -xf google-cloud-cli-linux-x86_64.tar.gz
yes | ./google-cloud-sdk/install.sh

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