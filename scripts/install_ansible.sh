#!/usr/bin/env bash
set -euo pipefail

# Install minimal dependencies required to run the ansible-local playbooks and Makefile targets
echo "Updating apt package index..."
sudo apt-get update

echo "Installing Ansible, make, and minimal prerequisites..."
DEBIAN_FRONTEND=noninteractive sudo apt-get install -y \
  ansible \
  make \
  git \
  curl \
  ca-certificates \
  gnupg \
  openssh-client \
  python3 \
  python3-apt \
  python3-pip \
  software-properties-common

echo ""
echo "Verifying installed versions:"
ansible --version | head -n 1
make --version | head -n 1
python3 --version
git --version

echo ""
echo "✅ Minimal Ansible dependencies installed! You can now run:"
echo "  cd ansible-local && make help"
