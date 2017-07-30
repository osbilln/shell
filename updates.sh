#!/bin/bash

for i in `cat servers`
  do
   echo 
   echo " ===================$i==================="
   ssh $i -C " yum clean all"
   ssh $i -C " yum update -y"
  done
