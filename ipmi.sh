#!/bin/bash
SERVER=$1

for i in `cat $SERVER`
  do
   echo $i
   ssh $i -C " yum clean all && yum install ipmitool OpenIPMI* -y " 
   ssh $i -C " service ipmi start and chkconfig impi on " 
  done
