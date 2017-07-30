#!/bin/bash

# nothing to commit (working directory clean)
# nothing added to commit but untracked files present (use "git add" to track)

pid=$$
echo "my pid = $pid"
# all child pids
ps -o pid --no-headers --ppid $pid

# ps -lef | grep -v grep | grep -v sudo | grep -v $pid | grep tomcatcron | grep -v grep | grep -c ""
cnt=$(ps -lef | grep -v grep | grep -v sudo | grep -v $pid | grep tomcatcron | grep -v grep | grep -c "") 
echo "running? = $cnt"

if [ $cnt -eq 0 ]; then

cd /var/www/cloudpass/data/
branch=$(git branch)
status=$(git status)
echo "branch: $branch  |  status: $status"
if [ $(echo $status | grep -c "untracked files") -gt 0 ] || [ $(echo $status | grep -c "Changes to be committed") -gt 0 ] || [ $(echo $status | grep -c "Changes not staged for commit") -gt 0 ] ; then
  echo "git add -A"
  /usr/bin/git add -A
  echo "git commit -a -m \"git@thecloudpass.com commits on FI-PROD-ASSETS-1A at `date +%Y%m%d-%H:%M:%S`\""
  /usr/bin/git commit -a -m "git@thecloudpass.com commits on FI-PROD-ASSETS-1A at `date +%Y%m%d-%H:%M:%S`"
  echo "git pull"
  /usr/bin/git pull
  echo "git push"
  /usr/bin/git push
else
  echo "git pull"
  /usr/bin/git pull
fi
echo "git status"
/usr/bin/git status

fi
