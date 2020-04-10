#!/bin/bash
#install dpendencies
cd ~/
curl -sL https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh -o install_nvm.sh
bash install_nvm.sh
source ~/.profile
nvm ls-remote
nvm install 12.16.2
nvm use 12.16.2
node -v
nvm ls
#install vim plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
cd ~/
#set neovim
#mkdir -p .config/nvim
#ln -s ~/.vimrc ~/.config/nvim/init.vim
#download configs 
wget https://raw.githubusercontent.com/micrometre/dotfiles/master/files/.vimrc
wget https://raw.githubusercontent.com/micrometre/dotfiles/master/files/.tmux.conf
wget https://raw.githubusercontent.com/micrometre/dotfiles/master/files/.tern-project
wget https://raw.githubusercontent.com/micrometre/dotfiles/master/files/.inputrc
wget https://raw.githubusercontent.com/micrometre/dotfiles/master/files/.bash_aliases




#install plugins
vim +'PlugInstall --sync' +qa    
