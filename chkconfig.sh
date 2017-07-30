#!/bin/bash

SERVER=$1
for i in `cat $SERVER`
  do
    echo "==================$i======================"
    ssh $i -C "chkconfig | grep 3:on"
    ssh $i -C "chkconfig auditd off"
    ssh $i -C "chkconfig udev-post off"
    ssh $i -C "chkconfig iptables off"
    ssh $i -C "chkconfig ip6tables off"
    ssh $i -C "chkconfig microcode_ctl off"
    ssh $i -C "chkconfig WebCoreTC off"
    echo "========================================== "
done
