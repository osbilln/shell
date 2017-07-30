#!/bin/bash
set -x
dashboards=$1
cd 
eval `ssh-agent`
ssh-add .au/id_rsa
# Need argunents
#
for i in `cat $dashboards`
  do
   cd /usr/java/$i/.customizations
    svn upgrade
    svn update
 done
