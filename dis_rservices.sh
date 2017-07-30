#!/bin/bash

for i in `cat dis_services` 
  do 
   echo $i 
   echo 
   chkconfig $i off
  done 
