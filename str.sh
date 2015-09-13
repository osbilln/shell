#!/bin/bash

SERVER=$1

for i in `cat $SERVER`
  do 
    ssh $i -C "apt-get update; apt-get install postfix"
    ssh $i -C "apt-get update; apt-get install rsync"
    ssh $i -C "svccfg import /var/svc/manifest/network/postfix.xml; svcadm enable svc:/network/postfix"
    ssh $i -C "groupadd -g 1005 nagios"
    ssh $i -C "useradd -g nagios -s /usr/bin/bash nagios"
    ssh $i -C "mkdir /export/home/nagios; chown nagios:nagios /export/home/nagios"
    ssh $i -C "mkdir /usr/local/nagios; chown nagios:nagios /usr/local/nagios"
    ssh $i -C "scp -rp /usr/"
  done
