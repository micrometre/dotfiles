#!/bin/bash
#install dependencies and kvm
export DEBIAN_FRONTEND=noninteractive
echo "Checking if CPU suports kvm"
egrep -c '(vmx|svm)' /proc/cpuinfo
sudo apt upgrade -y && \
sudo apt install -y \
qemu-kvm \
libvirt-daemon-system \
libvirt-clients \
bridge-utils \
virt-viewr
sudo adduser `id -un` libvirt
echo "Installation complete, you need to relogin to run virtual machines."
