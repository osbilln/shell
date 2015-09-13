#!/bin/bash

# for i in `cat slist`
#  do
   scp -rp /var/www/html/centos/6/os/x86_64/RPM* $1:
   ssh $1 -C "rpm --import RPM*"
   ssh $1 -C "yum clean all"
   ssh $1 -C "yum update -y --skip-broken"
#    ssh $1 -C "reboot"
# done
