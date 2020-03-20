#!/bin/sh

#git commit
pwd
commit-repo ()
{
commit_message1="comitted before rebuilding"
git add . -A
git commit -m "$commit_message1"
git push
}
commit-repo
