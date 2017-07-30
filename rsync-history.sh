#!/bin/bash
set -x
# %s/history\.orig/HISTORY-ORIG/g
# NOTE:

DATE=`date +%Y-%m-%d`
HISTORY-ORIG="./history.orig"

if [ $# != 1 ]
then
  echo "Option 1 is file type "
  exit
fi

if [ -e $1 ]
 then
   SERVER=`cat $1`
   rsync -azvt root@"$SERVER":.bash_history $SERVER.out.$DATE
   echo $SERVER
   scp -rp HISTORY-ORIG root@$SERVER:/root/.bash_history 
   echo $SERVER
 else
   SERVER=$1
   rsync -azvt root@$SERVER:.bash_history $SERVER.out.$DATE
   echo $SERVER
   scp -rp HISTORY-ORIG root@$SERVER:/root/.bash_history 
fi
