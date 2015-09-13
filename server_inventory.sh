#!/bin/bash

server_list=$1
for i in `cat $server_list`
 do
  echo $i >> $server_list_inventory.txt
  ssh billn@$i -C "ps auxf" >> $server_list_inventory.txt
  echo $i "=============================================" >> $server_list_inventory.txt
 done
