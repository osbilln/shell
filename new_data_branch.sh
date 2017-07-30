#!/bin/bash

if [ $# -eq 2 ]; then
  echo "cd /var/www/cloudpass/asset"
  cd /var/www/cloudpass/asset
  ls -l
  git branch -a
  git status
  current=$(git branch -a | grep "*" | awk '{print $2}')
  branch_exist=$(git branch -a | egrep "${2}$" | wc -l)
  if [ "$current" == "$1" ] && [ $branch_exist -eq 0 ]; then
    sudo -u tomcat7 -H /usr/bin/git pull
    sudo -u tomcat7 -H /usr/bin/git add -A
    sudo -u tomcat7 -H /usr/bin/git commit -a -m "git@thecloudpass.com create branch $2 on FI-PROD-ASSETS-1A at `date +%Y%m%d-%H:%M:%S`"
    sudo -u tomcat7 -H /usr/bin/git push
    sudo -u tomcat7 -H /usr/bin/git checkout master
    sudo -u tomcat7 -H /usr/bin/git pull
    sudo -u tomcat7 -H /usr/bin/git merge $1
    sudo -u tomcat7 -H /usr/bin/git push
    sudo -u tomcat7 -H /usr/bin/git checkout master -b $2
    sudo -u tomcat7 -H /usr/bin/git push -u origin $2
    sudo -u tomcat7 -H /usr/bin/git pull
    sudo -u tomcat7 -H /usr/bin/git status
  else
    echo "branch $2 already exist"
  fi
  cd -
else
  echo "$0 {current branch} {new branch}"
fi
