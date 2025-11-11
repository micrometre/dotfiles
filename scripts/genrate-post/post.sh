#!/bin/bash -xv
DATE="`date +%H`_`date +%M`_`date +%S`_`date +%d`_`date +%m`_`date +%y`.md"
#DATE=$(date '+%d/%m/%Y %H:%M:%S');
PORT=$1
DOMAIN=$2

./scripts/generate.sh 8080 domain.com > content/blogs/$DATE
