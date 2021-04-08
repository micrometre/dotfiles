#!/bin/bash
#install dpendencies
node -v
nvm ls
#install vim plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
cd ~/
wget https://raw.githubusercontent.com/micrometre/dotfiles/master/files/.vimrc
wget https://raw.githubusercontent.com/micrometre/dotfiles/master/files/.tmux.conf
wget https://raw.githubusercontent.com/micrometre/dotfiles/master/files/.tern-project
wget https://raw.githubusercontent.com/micrometre/dotfiles/master/files/.inputrc
wget https://raw.githubusercontent.com/micrometre/dotfiles/master/files/.bash_aliases
#install plugins
vim +'PlugInstall --sync' +qa    
