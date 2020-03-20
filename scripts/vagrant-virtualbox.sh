#!/bin/bash 
#install some base packages
sudo apt-get update && sudo apt-get install \
#add VirtualBox repository 
sudo sh -c 'echo "deb http://download.virtualbox.org/virtualbox/debian $(lsb_release -sc) contrib" >> /etc/apt/sources.list'
#ADD VIRTUALBOX REPOSITORY AND KEY
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- |  sudo apt-key add -
wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- |  sudo apt-key add -
sudo sh -c 'echo "deb http://download.virtualbox.org/virtualbox/debian $(lsb_release -sc) contrib" >> /etc/apt/sources.list'
#INSTALL VIRTUALBOX
sudo apt remove virtualbox virtualbox-5.*
sudo apt-get update -y
sudo apt-get -y install linux-headers-$(uname -r) dkms
sudo apt-get install -y virtualbox-6.0
VBoxManage -v
#INSTALL VIRTUALBOX EXTENSION PACK
cd ~/
wget http://download.virtualbox.org/virtualbox/5.2.0/Oracle_VM_VirtualBox_Extension_Pack-5.2.0-118431.vbox-extpack
VBoxManage extpack install Oracle_VM_VirtualBox_Extension_Pack-5.2.0-118431.vbox-extpack
rm Oracle_VM_VirtualBox_Extension_Pack-5.2.0-118431.vbox-extpack
VBoxManage list extpacks
#add user to vboxusers for usb 
sudo usermod -aG vboxusers $USER
#Install Vagrant
sudo apt-get update
cd
wget https://releases.hashicorp.com/vagrant/2.2.0/vagrant_2.2.0_x86_64.deb 
sudo dpkg -i vagrant_2.2.0_x86_64.deb
rm vagrant_2.2.0_x86_64.deb
sudo wget https://raw.github.com/kura/vagrant-bash-completion/master/etc/bash_completion.d/vagrant -O /etc/bash_completion.d/vagrant
#vagrant plugins
vagrant plugin install vagrant-vbguest
vagrant plugin install vagrant-hostsupdater
vagrant plugin install vagrant-lxd
sudo chown -R "$USER:$USER" .vagrant.d/
vagrant plugin list
