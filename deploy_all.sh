#!/bin/bash 

for i in `cat hosts | awk '{print $3}'`
   do 
    ssh $i -C "install-all"
   done
