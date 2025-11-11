#!/bin/bash -xv
RESOURCE_GROUP_NAME="VMResourceGroup"
REGION=uksouth
VM_NAME="microanpr"
USERNAME=ubuntu
VM_IMAGE="Canonical:0001-com-ubuntu-minimal-jammy:minimal-22_04-lts-gen2:latest"


az vm create \
    --resource-group $RESOURCE_GROUP_NAME \
    --name $VM_NAME \
    --image $VM_IMAGE \
    --admin-username $USERNAME \
    --size Standard_B2s \
    --assign-identity \
    --generate-ssh-keys \
    --public-ip-sku Standard \
   
az vm open-port --port 5000 --resource-group $RESOURCE_GROUP_NAME --name $VM_NAME --priority 1011
az vm open-port --port 5173 --resource-group $RESOURCE_GROUP_NAME --name $VM_NAME --priority 1021

