#!/bin/bash

NODE=$1
 for i in `cat $NODE`
   do 
     echo $i
     ssh $i -C "iptables -L |grep 4949"
     ssh $i -C "iptables -L |grep 5666"
     echo " ============================================================="
   done
