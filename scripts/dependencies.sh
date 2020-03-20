#!/bin/bashi
#install dependencies
export DEBIAN_FRONTEND=noninteractive
sudo apt upgrade -y && \
sudo apt install -y \
git \
build-essential \
make \
software-properties-common \
unzip \
curl \
wget \
openssh-server \
bash-completion \
vim \
python2.7 \
openssh-server \
tmux \
apt-transport-https \
ca-certificates \
aptitude \
python3.6-venv
python \
python-virtualenv \
python3-virtualenv \
python3-pip \
python3-dev \
python-pip  
# install  anseble from ppa 
sudo apt-add-repository ppa:ansible/ansible -y
sudo apt-get update
sudo apt-get install  ansible -y
sudo apt upgrade -y
sudo apt autoremove -y
