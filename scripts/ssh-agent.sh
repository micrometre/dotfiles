#!/bin/bash
if [ -z "$SSH_AUTH_SOCK" ]; then
  echo "No ssh agent detected"
else
  echo $SSH_AUTH_SOCK
  ssh-add -l
fi

  echo $SSH_AUTH_SOCK
