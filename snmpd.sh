#!/bin/bash

# SERVER=$*
SERVER=$1

# for i in $SERVER
for i in `cat $SERVER`
  do
   echo $i
   ssh $i -C "yum -y install net-snmp net-snmp-utils"
   scp -r ./snmpd.conf $i:/etc/snmp/snmpd.conf
   ssh $i -C "service snmpd stop"
   ssh $i -C "service snmpd start"
   snmpwalk  -v 1 -c sequentonly -O e $i
   echo " =========================================== "
  done
