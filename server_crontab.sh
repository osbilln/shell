#!/bin/bash

crontab=crontab.txt

for i in `cat server.list`
 do
  echo $i >> $crontab
  ssh billn@$i -C "sudo su - ; crontab -l " >> $crontab
  ssh billn@$i -C "sudo su - naehas ; crontab -l " >> $crontab
  echo $i "=============================================" >> $crontab
 done
