#!/bin/bash

SERVERS=$1
for i in `cat $SERVERS`
  do
   scp idmapd.conf $i:/etc/.
   ssh $i -C "chkconfig rpcbind on"
   ssh $i -C "	chkconfig nfslock on"
   ssh $i -C "	chkconfig netfs on"
   ssh $i -C "	chkconfig rpcidmapd on"
#
   ssh $i -C "service nfslock start"
   ssh $i -C "service netfs start"
   ssh $i -C "service rpcbind start"
   ssh $i -C "service rpcidmapd start"
  done
