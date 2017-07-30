#!/bin/bash


for i in `cat prod-cookbooks`
 do
  echo $i
   knife cookbook upload $i
done 
  
