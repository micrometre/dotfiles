#!/bin/bash
#install dependencies
sudo apt-get update && DEBIAN_FRONTEND=noninteractive  sudo apt-get install -y \
build-essential \
curl \
git \
build-essential \
make \
software-properties-common \
unzip \
bash-completion \
openssh-server \
tmux \
apt-transport-https \
ca-certificates \
aptitude \
python3-pip \
python3-dev \
wget 
sudo -H pip3 install --upgrade pip
sudo -H pip3 install virtualenv
