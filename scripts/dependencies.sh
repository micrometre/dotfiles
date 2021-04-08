#!/bin/bash
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
openssh-server \
tmux \
apt-transport-https \
ca-certificates \
aptitude \
python3 \
python3-pip \
python3-venv \
vim \
grip \
vprerex \
latexmk \
texlive-lang-english \
texlive-base \
texlive-latex-base \
texlive-latex-extra \
vim-gtk \
texmaker 
#vim-gtk # temp solution for enable +python feature in vim
sudo apt autoremove -y
