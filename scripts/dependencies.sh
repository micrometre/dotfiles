#!/bin/bash
#install dependencies
export DEBIAN_FRONTEND=noninteractive
sudo apt upgrade -y && \
sudo apt install -y \
git \
grip \
vprerex \
latexmk \
#vim-gtk # temp solution for enable +python feature in vim
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
python3 \
python3-pip \
python3-venv 
sudo apt autoremove -y
