#!/bin/sh

for i in `cat servers`
 do
   echo $i
   echo "" 
   ssh $i ' chkconfig ypbind on'
   echo ""
done
