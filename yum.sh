#!/bin/bash

for i in `cat servers.list`
  do
   echo $i
   scp -rp yum.conf $i:/etc/yum.conf
  done
