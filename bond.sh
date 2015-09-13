#!/bin/bash
scp -r ifcfg-bond0 $1:/etc/sysconfig/network-scripts/ifcfg-bond0
scp -r ifcfg-eth0 $1:/etc/sysconfig/network-scripts/
scp -r ifcfg-eth1 $1:/etc/sysconfig/network-scripts/
scp -r modprobe.conf $1:/etc
scp -r network $1:/etc/sysconfig/.
ssh $1 -C "reboot"
