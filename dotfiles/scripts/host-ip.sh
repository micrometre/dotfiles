#!/bin/bash -xv
RESOURCE_GROUP_NAME="VMResourceGroup"
REGION=uksouth
VM_NAME="microanpr"
USERNAME=ubuntu
VM_IMAGE="Canonical:0001-com-ubuntu-minimal-jammy:minimal-22_04-lts-gen2:latest"


#az vm show -d -g $RESOURCE_GROUP_NAME -n $VM_NAME --query publicIps

lb1_ip=$(az vm show -d -g $RESOURCE_GROUP_NAME -n $VM_NAME --query publicIps | tail -n 1)

cat  > inventory/microanpr <<EOL
[flaskanpr]
${lb1_ip}
EOL


sudo sed -i -e "/flask/s/^.*$/${lb1_ip} flaskanpr/"  /etc/hosts