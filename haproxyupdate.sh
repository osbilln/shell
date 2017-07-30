#!/bin/bash

# nothing to commit (working directory clean)
# nothing added to commit but untracked files present (use "git add" to track)

pid=$$
echo "my pid = $pid"
# all child pids
ps -o pid --no-headers --ppid $pid
cd 
eval `ssh-agent`
ssh-add .ssh/naehasops

cd /etc/haproxy
branch=$(git branch)
status=$(git status)
echo "branch: $branch  |  status: $status"
if [ $(echo $status | grep -c "working directory clean") -eq 0 ]; then
  echo "git add -A"
  /usr/bin/git add .
  /usr/bin/git commit -a -m "checking in updates `date +%Y%m%d-%H:%M:%S`"
  echo "git pull"
  /usr/bin/git pull
  echo "git push"
  /usr/bin/git push -u origin master
fi

ssh-agent -k