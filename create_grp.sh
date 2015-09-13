#!/bin/bash
if [ $# != 1 ]
then
  echo "Arg 1 must be an environment (host list etc.....)"
  exit
else
  SERVER=$1
  echo "$SERVER"
fi


for i in `cat $SERVER`
  do 
   echo $i 
   echo 
   ssh $i -C " groupadd -g 1002 techops "
   ssh $i -C " groupadd -g 1001 engs "
  done 

