#!/bin/bash
apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
cmake \
g++ \
pkg-config \
git vim-common \
libwebsockets-dev \
libjson-c-dev \
libssl-dev 
git clone https://github.com/tsl0922/ttyd.git
cd ttyd && mkdir build && cd build
cmake ..
make && make install
