#!/bin/bash

for i in `cat servers.list`
  do
   echo $i
   ssh $i -C "cat /etc/resolv.conf"
   scp -rp resolv.conf $i:/etc/resolv.conf
  done
