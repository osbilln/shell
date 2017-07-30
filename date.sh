#!/bin/bash

SERVERS=$1
for i in `cat $SERVERS`
  do
#
   echo $i " ======================================== "
   ssh $i -C "date"
#   scp -rp /usr/share/zoneinfo/GMT $i:/usr/share/zoneinfo/GMT 
   ssh $i -C " rm -f /etc/localtime"
   ssh $i -C "ln -s /usr/share/zoneinfo/GMT /etc/localtime"
   ssh $i -C "date"
  done
