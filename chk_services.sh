#!/bin/bash


for i in `cat slnames `
  do 
   echo $i 
   echo 
   ssh $i -C " chkconfig | grep 3:on | awk '{print $1}' " > $i.services 
  done 

