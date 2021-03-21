#display ssh public key
alias sshkey='cat ~/.ssh/id_rsa.pub'
#Command line interface for testing internet bandwidth using speedtest.net
alias speed-test='curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -'
#git commit/push 
#pass your 3 arguments like this example! bash git-commit.sh finished updatig configs
commit_repo ()
{
commit_message1="$1"
commit_message2="$2"
commit_message3="$3"
commit_message3="$4"
commit_message3="$5"
git add . -A
git commit -m "$commit_message1 $commit_message2 $commit_message3 $commit_message4 $commit_message5"
git push
}
#reset commit history
commit_reset()
{
commit_message1="$1"
commit_message2="$2"
commit_message3="$3"
commit_message3="$4"
commit_message3="$5"
git checkout --orphan TEMP_BRANCH
git add -A
git commit -am "$commit_message1 $commit_message2 $commit_message3 $commit_message4 $commit_message5"
git branch -D master
git branch -m master
git push -f origin master
git push --set-upstream origin master
}
#delete clear docker images, volumes and containers
docker_nuke () {
docker rm -f $(docker ps -a -q)
docker rmi -f $(docker images -q)
docker volume prune
docker network prune
}
mark_down ()
{
python3 -m venv edit-venv
source edit-venv/bin/activate
pip install grip
}

