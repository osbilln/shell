#!/bin/bash

timestamp=$(date +%Y/%m/%d_%H:%M:%S)
echo "$0 -- Starting backups at $timestamp"
for arg in $(cat /home/naehas/conf/subversion_instances.cfg)
do
   echo "$0 -- Backing up /usr/java/$arg"
   cd /usr/java/$arg/
   if [ $? -eq 0 ]; then
      if [[ -e _upgrade.lock ]]; then
         echo "Skipping /usr/java/$arg because it is locked for upgrade (_upgrade.lock file present)" 
      else
         svn add . --force
         svn update
         svn commit -m "Autocommit from $0"
      fi
   else 
      echo "cd /usr/java/$arg/ did not work."
   fi
done
timestamp=$(date +%Y/%m/%d_%H:%M:%S)
echo "$0 -- Backups finished at $timestamp"
