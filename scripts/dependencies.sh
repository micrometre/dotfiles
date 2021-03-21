#!/bin/bash
#install dependencies
export DEBIAN_FRONTEND=noninteractive
sudo apt upgrade -y && \
sudo apt install -y \
git \
grip \
build-essential \
make \
software-properties-common \
unzip \
curl \
wget \
openssh-server \
bash-completion \
vim \
openssh-server \
tmux \
apt-transport-https \
ca-certificates \
aptitude \
python3-pip \
python3-venv 
sudo apt autoremove -y
