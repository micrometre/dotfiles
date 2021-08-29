#!/bin/bash -xv

sudo apt-get update && sudo apt-get install \
  sudo apt-transport-https ca-certificates curl software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/debian \
  $(lsb_release -cs) \
  stable"

sudo apt-get update && sudo apt-get install \
  docker-ce \
  docker-ce-cli\
  containerd.io

sudo usermod -aG docker ${USER}
