#!/bin/bash
set -x

DATE=`date +%Y-%m-%d-%M`
function backup_passwd () {
  cp /etc/passwd /etc/passwd.$DATE
  cp /etc/group /etc/group.$DATE
  cp /etc/shadow /etc/shadow.$DATE
  cp /etc/sudoers /etc/sudoers.$DATE
}

backup_passwd
cd /home
find . -maxdepth 1 -type d | cut -d/ -f2  | grep -v ubuntu | grep -v naehas | grep -v mysql | sort -n | sed '1d;$d' | while read userid; do
    deluser $userid
    chown -R $userid:naehas $userid
  done
