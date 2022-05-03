#!/bin/bash -xv
#install dependencies
sudo apt-get update && DEBIAN_FRONTEND=noninteractive  sudo apt-get install -y \
build-essential \
curl \
git \
git-core \
zlib1g-dev \
build-essential \
libssl-dev \
libreadline-dev \
libyaml-dev \
libsqlite3-dev \
sqlite3 \
libxml2-dev \
libxslt1-dev \
libcurl4-openssl-dev \
software-properties-common 


cd
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
exec $SHELL

git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
exec $SHELL

rbenv install 3.1.2
rbenv global 3.1.2

ruby -v

gem install bundler
