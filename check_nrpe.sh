#!/bin/bash


NAGIOS=/usr/local/nagios
SERVER=$*

for i in `cat $SERVER `
# for i in $SERVER
  do
   echo $i
#
#    scp -rp nrpe.cfg.util $i:/etc/nagios/nrpe.cfg
#
    scp -rp nrpe.xinetd_rs $i:/etc/xinetd.d/nrpe
    scp -rp nrpe.cfg_rs $i:/etc/nagios/nrpe.cfg
    ssh $i -C "service nrpe restart"
    ssh $i -C "service xinetd restart"
    /usr/local/nagios/libexec/check_nrpe -H $i -c check_users
   echo " =============================================== "
  done
