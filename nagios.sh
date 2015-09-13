#!/bin/bash

if [ $# != 1 ]
 then
  echo "Usage: $0 "Node file" "
  exit 
 else
  NODE=$1
fi
 for i in `cat $NODE `
   do 
     echo $i
#      ssh $i -C "apt-get install nagios-nrpe-server -y"
#      ssh $i -C "cd /etc/nagios && mv nrpe.cfg nrpe.cfg_ORIG "
     scp -r nrpe.cfg $i:/etc/nagios/
     ssh $i -C "service nagios-nrpe-server stop"
     ssh $i -C "service nagios-nrpe-server start"
#      ssh $i -C "ufw allow from 10.176.42.187 to any port 5666 "
#      ssh $i -C "chkconfig |grep nagios "
#      ssh $i -C "ufw allow from 10.176.42.187 to any port 5666 "
     echo " ============================================================="
   done
