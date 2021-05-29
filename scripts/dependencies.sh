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
vim \
grip \
vprerex \
latexmk \
texlive-lang-english \
texlive-base \
texlive-latex-base \
texlive-latex-extra \
texmaker \
libssl-dev \
libffi-dev
#sudo -H pip3 install --upgrade pip
#sudo -H pip3 install virtualenv
