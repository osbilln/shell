#!/bin/bash
SERVER=$1

for i in `cat hosts | awk '{print $3}'`
  do
   echo $i
   ssh $i -C "apt-get install autofs"
   scp -r auto.master $i:/etc/
   scp -r auto.shared $i:/etc/
   sleep 10
  done
