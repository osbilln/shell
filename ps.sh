#!/bin/bash

SERVER=$1
for i in `cat $SERVER`
  do
    echo $
    ssh $i -C "chkconfig | grep on"
    done
