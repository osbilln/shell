#!/bin/bash
for i in `cat slist`
do
  ssh $i -C "yum update -y"
  echo $i
  ssh $i -C "chkconfig --list | grep 3:on" >> chkconfig.log
 echo "================================================="
done
