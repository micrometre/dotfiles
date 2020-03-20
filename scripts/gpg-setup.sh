#!/bin/bash
#Generating a new GPG key
gpg --full-generate-key 
#output the generated key ID  
#gpg --list-keys  --keyid-format LONG | awk '{print $2}' | xargs | awk '{print $1}' | cut -c 9- | gpg --armor --export
#setup git config with the generated key 
gpg --list-keys  --keyid-format LONG | awk '{print $2}' | xargs | awk '{print $1}' | cut -c 9- | xargs git config --global user.signingkey 
#Sign commits automatically
git config --global commit.gpgSign true
#Add GPG key to  bash profile
test -r ~/.profile && echo 'export GPG_TTY=$(tty)' >> ~/.profile
echo 'export GPG_TTY=$(tty)' >> ~/.profile
