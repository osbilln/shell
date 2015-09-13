#!/bin/bash

SERVER=$*
SERVICES="activemq pentaho seq tomcat aggregator"
DIR=/data/etc/init.d

for i in `cat $SERVER `
  do
   echo $i
    for j in $SERVICES 
     do
     echo $i
     echo $j
     scp -rp $DIR/$j $i:/etc/init.d/.
     echo " =============================================== "
    done
done
