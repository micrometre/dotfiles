#!/bin/bash -x

cd ~/
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim +'PlugInstall --sync' +qa
git clone https://github.com/Yggdroot/indentLine.git ~/.vim/pack/vendor/start/indentLine
vim -u NONE -c "helptags  ~/.vim/pack/vendor/start/indentLine/doc" -c "q"
