#!/bin/bash

for i in cpfnonproddb
  do
    echo $i
    scp -rp /usr/share/munin/plugins/mongo* $i:/usr/share/munin/plugins/.
    ssh $i -C "cd /etc/munin/plugins/ && ln -s /usr/share/munin/plugins/mongo_btree ./"
    ssh $i -C "cd /etc/munin/plugins/ && ln -s /usr/share/munin/plugins/mongo_conn ./"
    ssh $i -C "cd /etc/munin/plugins/ && ln -s /usr/share/munin/plugins/mongo_lock ./"
    ssh $i -C "cd /etc/munin/plugins/ && ln -s /usr/share/munin/plugins/mongo_mem ./"
    ssh $i -C "cd /etc/munin/plugins/ && ln -s /usr/share/munin/plugins/mongo_ops ./"
    echo " `uname -n` ==============================="
   done
