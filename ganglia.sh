#!/bin/bash
SERVER=$1

# for i in `cat $SERVER`
for i in $SERVER
  do
   echo $i
#   ssh $i -C "yum clean all && yum install ganglia-gmond -y "
#   ssh $i -C "chkconfig gmond on"
#   scp gmond.conf $i:/etc/ganglia/.
   ssh $i -C "service gmond restart"
  done
