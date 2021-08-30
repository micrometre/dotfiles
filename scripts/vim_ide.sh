#!/bin/bash
nvm ls
#install vim plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
cd ~/
#install plugins
vim +'PlugInstall --sync' +qa
