#!/bin/bash

SERVER=$1

for i in $SERVER
  do
    echo $
#    ssh $i -C "apt-get install munin-node chkconfig -y"
    scp -rp munin-node.conf $i:/etc/munin
#    ssh $i -C "ufw allow from 10.176.42.187 to any port 4949"
#    ssh $i -C "iptables -L | grep 4949"
    ssh $i -C "service munin restart"
    ssh $i -C "chkconfig | grep on"
    echo " `uname -n` ==============================="
   done

for S in `cat service.text`
  do
        ssh $SERVER -C "cd /etc/munin/plugins/ && ln -s /usr/share/munin/plugins/$S ./"
  done
ssh $SERVER -C "service munin-node restart "

