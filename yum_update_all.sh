#!/bin/bash
#

if [ $# != 1 ]
then
  echo "Arg 1 must be an environment (host list etc.....)"
  exit
else
  SERVER=$1
  echo "$SERVER"
fi

KEYS="-i sq"

for HOST in `cat $SERVER | awk "{print $1}" `
 do 
 echo $i
 echo ===============================
 ssh $KEYS $HOST -C "yum update"
 echo 
done 
