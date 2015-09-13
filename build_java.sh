#!/bin/bash

if [ $# != 1 ]
then
  echo "Arg 1 must be an environment (host list etc.....)"
  exit
else
  VER=$1
  echo "$SERVER"
fi

cd /data 
/usr/bin/fpm -s dir -t rpm -n seq_java -v $VER usr/java
