#!/bin/bash

NODE=$1
 for i in `cat $NODE`
   do 
     echo $i
     ssh $i -C "php -v"
     echo " ============================================================="
   done
