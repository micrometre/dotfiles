#!/bin/bash -xv
RESOURCE_GROUP_NAME="VMResourceGroup"
REGION=uksouth
VM_NAME="microanpr"
USERNAME=ubuntu
VM_IMAGE="Canonical:0001-com-ubuntu-minimal-jammy:minimal-22_04-lts-gen2:latest"

az group create --name $RESOURCE_GROUP_NAME --location $REGION
