#!/bin/bash -xv

RESOURCE_GROUP_NAME="VMResourceGroup"
REGION=uksouth
VM_NAME="microanpr"
username=ubuntu
VM_IMAGE="Canonical:0001-com-ubuntu-minimal-jammy:minimal-22_04-lts-gen2:latest"



az vm delete \
    --resource-group $RESOURCE_GROUP_NAME \
    --name $VM_NAME \
    --yes
