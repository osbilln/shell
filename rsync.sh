#!/bin/bash

RSYNCNET="8456@usw-s008.rsync.net"
for i in `cat rsync.txt`
  do
   echo $i
    ssh $RSYNCNET -C "du -sh $i"
  done
