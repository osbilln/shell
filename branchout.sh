#!/bin/bash

if [ $# -eq 2 ]; then
  echo "cd /export/www/cloudpass/data"
  cd /export/www/cloudpass/data
  ls -l
  sudo -u tomcat7 -H /usr/bin/git branch -a
  sudo -u tomcat7 -H /usr/bin/git checkout $1
  sudo -u tomcat7 -H /usr/bin/git status
  current=$(sudo -u tomcat7 -H /usr/bin/git branch -a | grep "*" | awk '{print $2}')
  branch_exist=$(sudo -u tomcat7 -H /usr/bin/git branch -a | egrep "${2}$" | wc -l)
  echo $current
  echo $branch_exist
  if [ "$current" == "$1" ] && [ "$branch_exist" == "0" ]; then
    sudo -u tomcat7 -H /usr/bin/git pull
    read -p "Press [Enter] key to run command \"git add -A\""
    sudo -u tomcat7 -H /usr/bin/git add -A
    read -p "Press [Enter] key to run command \"git commit -a -m\""
    sudo -u tomcat7 -H /usr/bin/git commit -a -m "git@thecloudpass.com create branch $2 on FI-PROD-ASSETS-1A at `date +%Y%m%d-%H:%M:%S`"
    read -p "Press [Enter] key to run command \"git push origin $current\""
    sudo -u tomcat7 -H /usr/bin/git push origin $current
    read -p "Press [Enter] key to run command \"git checkout master\""
    sudo -u tomcat7 -H /usr/bin/git checkout master
    read -p "Press [Enter] key to run command \"git pull\""
    sudo -u tomcat7 -H /usr/bin/git pull
    # http://stackoverflow.com/questions/914939/simple-tool-to-accept-theirs-or-accept-mine-on-a-whole-file-using-git
    read -p "Press [Enter] key to run command \"git merge -s recursive -X ours $1\""
    sudo -u tomcat7 -H /usr/bin/git merge -s recursive -X ours $1
    read -p "Press [Enter] key to run command \"git push origin master\""
    sudo -u tomcat7 -H /usr/bin/git push origin master
    read -p "Press [Enter] key to run command \"git checkout master -b $2\""
    sudo -u tomcat7 -H /usr/bin/git checkout master -b $2
    read -p "Press [Enter] key to run command \"git push -u origin $2\""
    sudo -u tomcat7 -H /usr/bin/git push -u origin $2
    read -p "Press [Enter] key to run command \"git pull\""
    sudo -u tomcat7 -H /usr/bin/git pull
    sudo -u tomcat7 -H /usr/bin/git add -A
    sudo -u tomcat7 -H /usr/bin/git commit -m "receive all changes from master branch"
    sudo -u tomcat7 -H /usr/bin/git push
    sudo -u tomcat7 -H /usr/bin/git status
    sudo -u tomcat7 -H /usr/bin/git status
  else
    echo "branch $2 already exist"
  fi
  cd -
else
  echo "$0 {current branch} {new branch}"
  echo "ex: ./branch_out_data_repo.sh identity-1.1 identity-1.1.1"
  cd /export/www/cloudpass/data
  sudo -u tomcat7 -H /usr/bin/git branch
  cd -
fi
