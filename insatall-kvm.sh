#!/bin/bash
#install dependencies
export DEBIAN_FRONTEND=noninteractive
echo "Checking if CPU suports kvm"
egrep -c '(vmx|svm)' /proc/cpuinfo
sudo apt upgrade -y && \
sudo apt install -y \
qemu-kvm \
libvirt-daemon-system \
libvirt-clients \
virtinst \
cpu-checker \
libguestfs-tools \
libosinfo-bin \
bridge-utils
