#!/bin/bash -xv
echo 'deb http://deb.debian.org/debian buster-backports main' | sudo tee  -a /etc/apt/sources.list > /dev/null
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
sudo apt-get update && DEBIAN_FRONTEND=noninteractive  sudo apt-get install -y \
ansible
