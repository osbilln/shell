#!/bin/bash
set -x
SERVERS=$1
for i in `cat hosts | awk '{print $3}'`
  do
  echo " $i "
# MOVE TO ORIG
   ssh $i -C "cd /etc && /bin/mv ntp.conf ntp.conf.o"
   ssh $i -C "cd /etc && /bin/mv localtime localtime.o"
   ssh $i -C "ln -s /usr/share/zoneinfo/GMT /etc/localtime"
#
# COPY GMT time zone, clock, ntp.conf
   ssh $i -C "apt-get update && apt-get install ntp --yes-force"
   ssh $i -C "service ntp stop"
   ssh $i -C "ntpdate pool.ntp.org"
   ssh $i -C "service ntp start"
   ssh $i -C "update-rc-d ntp defaults "
   ssh $i -C "date"
  echo " ============================== "
  done
