
#!/bin/bash -xv
#install dependencies
sudo apt-get update && DEBIAN_FRONTEND=noninteractive  sudo apt-get install -y \
vprerex \
evince \
latexmk \
texlive-lang-english \
texlive-base 
