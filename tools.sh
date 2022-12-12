#!/bin/bash

echo "Enter Customer Connect Username:" 
read username
read -s -p "Enter Customer Connect Password: " mypassword
export VMD_USER=$username
export VMD_PASS=$mypassword
echo "Installing vmd"
if [ ! -f  /usr/local/bin/vmd ]; then
      wget -q https://github.com/laidbackware/vmd/releases/download/v0.3.0/vmd-linux-v0.3.0
      sudo install vmd-linux-v0.3.0 /usr/local/bin/vmd
      rm -f vmd-linux-v0.3.0
fi

echo "Installing govc"
if [ ! -f  /usr/local/bin/govc ]; then
    wget -q https://github.com/vmware/govmomi/releases/download/v0.27.5/govc_Linux_x86_64.tar.gz
    tar -xf govc_Linux_x86_64.tar.gz
    sudo install govc /usr/local/bin/govc
    rm -f govc_Linux_x86_64.tar.gz
    rm -f govc
    rm -f CHANGELOG.md
    rm -f LICENSE.txt
    rm -f README.md
fi

echo "Installing ytt"
if [ ! -f  /usr/local/bin/ytt ]; then
    wget -q https://github.com/vmware-tanzu/carvel-ytt/releases/download/v0.41.1/ytt-linux-amd64
    sudo install ytt-linux-amd64 /usr/local/bin/ytt 
    rm -f ytt-linux-amd64
fi

echo "Installing docker"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-get -qq update
sudo apt-get -qq install -y ca-certificates curl gnupg lsb-release jq docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo usermod -aG docker ubuntu

echo "Installing kind"
if [ ! -f  /usr/local/bin/kind ]; then
    wget -q https://kind.sigs.k8s.io/dl/v0.14.0/kind-linux-amd64
    sudo install kind-linux-amd64 /usr/local/bin/kind
    rm -f kind-linux-amd64
fi

echo "Installing flux"
if [ ! -f  /usr/local/bin/flux ]; then
    curl -s https://fluxcd.io/install.sh | sudo bash
fi

echo "Installing tfctl"
if [ ! -f  /usr/local/bin/tfctl ]; then
    wget -q https://github.com/weaveworks/tf-controller/releases/download/v0.13.1/tfctl_Linux_amd64.tar.gz
    tar -xf tfctl_Linux_amd64.tar.gz
    sudo install tfctl /usr/local/bin/tfctl
    rm -f tfctl
fi

echo "Installing Tanzu"
if [ ! -f  /usr/local/bin/tanzu ]; then
    # export VMD_USER="$1"
    # export VMD_PASS="$2"
    rm -rf cli 
    vmd download -p vmware_tanzu_kubernetes_grid -s tkg -v 1.6.0 -f 'tanzu-cli-bundle-linux-amd64.*' --accepteula
    tar -xf $HOME/vmd-downloads/tanzu-cli-bundle-linux-amd64.tar.gz
    tanzu_cli=$(find . -name tanzu-core-linux_amd64)
    sudo install $tanzu_cli /usr/local/bin/tanzu
    tanzu init 
    tanzu plugin list
    rm -rf cli
fi

echo "Installing kubectl"
if [ ! -f  /usr/local/bin/kubectl ]; then
    # export VMD_USER="$1"
    # export VMD_PASS="$2"
    vmd download -p vmware_tanzu_kubernetes_grid -s tkg -v 1.6.0 -f 'kubectl-linux-*' --accepteula
    gunzip $HOME/vmd-downloads/kubectl-linux*.gz
    kubectlcli=$(find . -name kubectl-linux*)
    sudo install $kubectlcli /usr/local/bin/kubectl
    rm -f $kubectlcli
fi

if [ -f  /usr/local/bin/kubectl ]; then
echo "Adding bash completion"
echo 'source <(kubectl completion bash)' >>~/.bashrc
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -o default -F __start_kubectl k' >>~/.bashrc
fi
unset VMD_PASS
unset VMD_USER
