#!/bin/bash

if [ $# != 2 ]
then
  echo "Arg 1 must be an environment Location (rackspace, vivo, softlayer, etc.....)"
  echo "Arg 2 must be a file type "
  exit
fi

if [ -n $1 ]
 then
   ENV=$1
   echo $ENV
 else
   exit 1
fi

if [ -e $2 ]
 then
   SERVER=`cat $2`
   echo $SERVER
 else
   SERVER=$2
   echo $SERVER
fi


for i in $SERVER
  do
   echo $i
   ssh $i -C "cp -rp /etc/resolv.conf /etc/resolv.conf_ORIG"
   ssh $i -C "cp -rp /etc/nsswitch.conf /etc/nsswitch..conf_ORIG"
   scp -rp resolv.conf $i:/etc/resolv.conf
   scp -rp nsswitch.conf $i:/etc/.
  done
