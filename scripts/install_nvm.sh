#!/bin/bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
source ~/.bashrc
source ~/.profile
npm  install -g nodemon browser-sync autocannon serve markdown-preview
