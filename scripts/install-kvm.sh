#!/bin/bash
#install dependencies
export DEBIAN_FRONTEND=noninteractive
sudo apt upgrade -y && \
sudo apt install -y \
qemu-kvm \
libvirt-daemon-system \
libvirt-clients \
bridge-utils
